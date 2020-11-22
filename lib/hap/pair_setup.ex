defmodule HAP.PairSetup do
  @moduledoc """
  Implements the Pair Setup flow described in Apple's [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/). 

  Since Pair Setup is a singleton operation, this is implemented as a named GenServer
  """

  use GenServer

  require Logger

  alias HAP.AccessoryServerManager
  alias HAP.Crypto.{ChaCha20, EDDSA, HKDF, SRP6A}

  # We intentionally structure our constant names to match those in the HAP specification
  # credo:disable-for-this-file Credo.Check.Readability.ModuleAttributeNames
  # credo:disable-for-this-file Credo.Check.Readability.VariableNames

  @i "Pair-Setup"
  @kTLVType_Method 0x00
  @kTLVType_Identifier 0x01
  @kTLVType_Salt 0x02
  @kTLVType_PublicKey 0x03
  @kTLVType_Proof 0x04
  @kTLVType_EncryptedData 0x05
  @kTLVType_State 0x06
  @kTLVType_Error 0x07
  @kTLVType_Signature 0x0A

  @kTLVError_Authentication <<0x02>>
  @kTLVError_Unavailable <<0x06>>
  @kTLVError_Busy <<0x07>>

  @kFlag_Admin <<0x01>>

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def handle_message(message, pid \\ __MODULE__) do
    GenServer.call(pid, message)
  end

  def init(_opts) do
    HAP.Display.update_pairing_info_display()
    {:ok, %{step: 1}}
  end

  # Handles `<M1>` messages and returns `<M2>` messages
  def handle_call(%{@kTLVType_State => <<1>>, @kTLVType_Method => <<0>>}, _from, %{step: 1} = state) do
    if AccessoryServerManager.paired?() do
      Logger.error("Pair-Setup <M1> Already paired")
      response = %{@kTLVType_State => <<2>>, @kTLVType_Error => @kTLVError_Unavailable}
      {:reply, {:ok, response}, state}
    else
      p = AccessoryServerManager.pairing_code()
      {:ok, s, v} = SRP6A.verifier(@i, p)
      {:ok, auth_context, b} = SRP6A.auth_context(v)

      response = %{@kTLVType_State => <<2>>, @kTLVType_PublicKey => b, @kTLVType_Salt => s}
      {:reply, {:ok, response}, %{step: 3, auth_context: auth_context, salt: s}}
    end
  end

  def handle_call(%{@kTLVType_State => <<1>>, @kTLVType_Method => <<0>>}, _from, state) do
    Logger.error("Pair-Setup <M1> Already pairing")
    response = %{@kTLVType_State => <<2>>, @kTLVType_Error => @kTLVError_Busy}
    {:reply, {:ok, response}, state}
  end

  # Handles `<M3>` messages and returns `<M4>` messages
  def handle_call(
        %{@kTLVType_State => <<3>>, @kTLVType_PublicKey => a, @kTLVType_Proof => proof},
        _from,
        %{step: 3, auth_context: auth_context, salt: s} = state
      ) do
    {:ok, m_1, m_2, k} = SRP6A.shared_key(auth_context, a, @i, s)

    if proof == m_1 do
      response = %{@kTLVType_State => <<4>>, @kTLVType_Proof => m_2}
      {:reply, {:ok, response}, %{step: 5, session_key: k}}
    else
      Logger.error("Pair-Setup <M3> Provided proof does not match")
      response = %{@kTLVType_State => <<4>>, @kTLVType_Error => @kTLVError_Authentication}
      {:reply, {:ok, response}, state}
    end
  end

  # Handles `<M5>` messages and returns `<M6>` messages
  #
  # Note that the specifics of deriving the envelope key are not described in R1 or R2 of the HAP specification;
  # guidance was taken from other third-party implementations for the specific key material to use
  #
  def handle_call(
        %{@kTLVType_State => <<5>>, @kTLVType_EncryptedData => encrypted_data},
        _from,
        %{step: 5, session_key: session_key} = state
      ) do
    with {:ok, envelope_key} <- HKDF.generate(session_key, "Pair-Setup-Encrypt-Salt", "Pair-Setup-Encrypt-Info"),
         {:ok, tlv} <- ChaCha20.decrypt_and_verify(encrypted_data, envelope_key, "PS-Msg05"),
         {:ok, ios_identifier, ios_ltpk} <- extract_ios_device_exchange(tlv, session_key),
         {:ok, response_sub_tlv} <-
           build_accessory_device_exchange(
             AccessoryServerManager.identifier(),
             AccessoryServerManager.ltpk(),
             AccessoryServerManager.ltsk(),
             session_key
           ),
         {:ok, encrypted_response} <- ChaCha20.encrypt_and_tag(response_sub_tlv, envelope_key, "PS-Msg06") do
      AccessoryServerManager.add_controller_pairing(ios_identifier, ios_ltpk, @kFlag_Admin)

      Logger.info("Successfully paired with controller #{ios_identifier}")

      HAP.Discovery.reload()

      response = %{
        @kTLVType_State => <<6>>,
        @kTLVType_EncryptedData => encrypted_response
      }

      {:reply, {:ok, response}, %{step: 1}}
    else
      {:error, reason} ->
        Logger.error("Pair-Setup <M5> Encountered error: #{reason}")
        response = %{@kTLVType_State => <<6>>, @kTLVType_Error => @kTLVError_Authentication}
        {:reply, {:ok, response}, state}
    end
  end

  def handle_call(tlv, _from, state) do
    Logger.error("Pair-Setup Received unexpected message: #{inspect(tlv)}, state: #{inspect(state)}")
    {:reply, {:error, "Unexpected message for pairing state"}, %{step: 1}}
  end

  defp extract_ios_device_exchange(tlv, session_key) do
    tlv
    |> HAP.TLVParser.parse_tlv()
    |> case do
      %{
        @kTLVType_Identifier => ios_identifier,
        @kTLVType_PublicKey => ios_ltpk,
        @kTLVType_Signature => ios_signature
      } ->
        {:ok, ios_device_x} =
          HKDF.generate(session_key, "Pair-Setup-Controller-Sign-Salt", "Pair-Setup-Controller-Sign-Info")

        ios_device_info = ios_device_x <> ios_identifier <> ios_ltpk

        case EDDSA.verify(ios_device_info, ios_signature, ios_ltpk) do
          {:ok, true} -> {:ok, ios_identifier, ios_ltpk}
          _ -> {:error, "Key Verification Error"}
        end

      _ ->
        {:error, "TLV Parsing Error"}
    end
  end

  defp build_accessory_device_exchange(accessory_identifier, accessory_ltpk, accessory_ltsk, session_key) do
    {:ok, accessory_x} = HKDF.generate(session_key, "Pair-Setup-Accessory-Sign-Salt", "Pair-Setup-Accessory-Sign-Info")
    accessory_info = accessory_x <> accessory_identifier <> accessory_ltpk
    {:ok, accessory_signature} = EDDSA.sign(accessory_info, accessory_ltsk)

    sub_tlv = %{
      @kTLVType_Identifier => accessory_identifier,
      @kTLVType_PublicKey => accessory_ltpk,
      @kTLVType_Signature => accessory_signature
    }

    {:ok, HAP.TLVEncoder.to_binary(sub_tlv)}
  end
end
