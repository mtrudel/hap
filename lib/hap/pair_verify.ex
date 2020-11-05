defmodule HAP.PairVerify do
  @moduledoc """
  Implements the Pair Verify flow described in Apple's [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/). 
  """

  use GenServer

  require Logger

  alias HAP.Accessory
  alias HAP.Crypto.{HKDF, ChaCha20, ECDH, EDDSA}

  @kTLVType_Identifier 0x01
  @kTLVType_PublicKey 0x03
  @kTLVType_EncryptedData 0x05
  @kTLVType_State 0x06
  @kTLVType_Error 0x07
  @kTLVType_Signature 0x0A

  @kTLVError_Authentication <<0x02>>

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def handle_message(message, pid \\ __MODULE__) do
    GenServer.call(pid, message)
  end

  def init(_opts) do
    {:ok, %{step: 1}}
  end

  @doc """
  Handles `<M1>` messages and returns `<M2>` messages
  """
  def handle_call(%{@kTLVType_State => <<1>>, @kTLVType_PublicKey => ios_epk}, _from, %{step: 1}) do
    {:ok, accessory_epk, accessory_esk} = ECDH.key_gen()
    {:ok, session_key} = ECDH.compute_key(ios_epk, accessory_esk)
    accessory_info = accessory_epk <> Accessory.identifier() <> ios_epk
    {:ok, accessory_signature} = EDDSA.sign(accessory_info, Accessory.ltsk())

    resp_sub_tlv =
      %{
        @kTLVType_Identifier => Accessory.identifier(),
        @kTLVType_Signature => accessory_signature
      }
      |> HAP.TLVEncoder.to_binary()

    {:ok, hashed_k} = HKDF.generate(session_key, "Pair-Verify-Encrypt-Salt", "Pair-Verify-Encrypt-Info")
    {:ok, encrypted_data_and_tag} = ChaCha20.encrypt_and_tag(resp_sub_tlv, hashed_k, "PV-Msg02")

    response = %{
      @kTLVType_State => <<2>>,
      @kTLVType_PublicKey => accessory_epk,
      @kTLVType_EncryptedData => encrypted_data_and_tag
    }

    {:reply, {:ok, response}, %{step: 3, session_key: session_key}}
  end

  @doc """
  Handles `<M3>` messages and returns `<M4>` messages
  """
  def handle_call(%{@kTLVType_State => <<3>>, @kTLVType_EncryptedData => encrypted_data_and_tag}, _from, %{
        step: 3,
        session_key: session_key
      }) do
    with {:ok, hashed_k} <- HKDF.generate(session_key, "Pair-Verify-Encrypt-Salt", "Pair-Verify-Encrypt-Info"),
         {:ok, tlv} <- ChaCha20.decrypt_and_verify(encrypted_data_and_tag, hashed_k, "PV-Msg03") do
      tlv
      |> HAP.TLVParser.parse_tlv()
      |> IO.inspect(limit: :infinity)

      #  1 => "EBFB8A82-9E40-499E-BD51-3242D7099E85",
      # 10 => <<182, 128, 174, 144, 208, 224, 202, 24, 107, 108, 246, 57, 227, 80,
      # 140, 46, 53, 10, 225, 161, 136, 17, 238, 1, 60, 67, 79, 233, 212, 88, 159,
      # 104, 237, 75, 92, 206, 30, 151, 53, 140, 176, 56, 167, 253, 147, 74, 164,
      # 194, 145, 169, 104, 220, 59, 158, 176, 112, 3, 167, 158, 213, 44, 40, 136,
      # 1>>
      # TODO -- compare this to our existing LTPK for this device and return error(s)

      {:reply, {:ok, %{@kTLVType_State => <<3>>}}, %{step: 4, session_key: session_key}}
    else
      {:error, _} ->
        response = %{@kTLVType_State => <<3>>, @kTLVType_Error => @kTLVError_Authentication}
        {:reply, {:ok, response}, %{step: 4, session_key: session_key}}
    end
  end

  def handle_message(tlv, _from, state) do
    Logger.error("Received unexpected message for pairing state. Message: #{inspect(tlv)}, state: #{inspect(state)}")
    {:error, "Unexpected message for pairing state"}
  end
end
