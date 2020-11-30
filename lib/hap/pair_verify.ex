defmodule HAP.PairVerify do
  @moduledoc false
  # Implements the Pair Verify flow described in Apple's [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/). 

  require Logger

  alias HAP.{AccessoryServerManager, TLVEncoder, TLVParser}
  alias HAP.Crypto.{ChaCha20, ECDH, EDDSA, HKDF}

  # We intentionally structure our constant names to match those in the HAP specification
  # credo:disable-for-this-file Credo.Check.Readability.ModuleAttributeNames
  # credo:disable-for-this-file Credo.Check.Readability.VariableNames

  @kTLVType_Identifier 0x01
  @kTLVType_PublicKey 0x03
  @kTLVType_EncryptedData 0x05
  @kTLVType_State 0x06
  @kTLVType_Error 0x07
  @kTLVType_Signature 0x0A

  @kTLVError_Authentication <<0x02>>

  @kFlag_Admin <<0x01>>

  def init do
    %{step: 1}
  end

  @doc false
  # Handles `<M1>` messages and returns `<M2>` messages
  def handle_message(%{@kTLVType_State => <<1>>, @kTLVType_PublicKey => ios_epk}, %{step: 1}) do
    {:ok, accessory_epk, accessory_esk} = ECDH.key_gen()
    {:ok, session_key} = ECDH.compute_key(ios_epk, accessory_esk)
    accessory_info = accessory_epk <> AccessoryServerManager.identifier() <> ios_epk
    {:ok, accessory_signature} = EDDSA.sign(accessory_info, AccessoryServerManager.ltsk())

    resp_sub_tlv =
      %{
        @kTLVType_Identifier => AccessoryServerManager.identifier(),
        @kTLVType_Signature => accessory_signature
      }
      |> TLVEncoder.to_binary()

    {:ok, hashed_k} = HKDF.generate(session_key, "Pair-Verify-Encrypt-Salt", "Pair-Verify-Encrypt-Info")
    {:ok, encrypted_data_and_tag} = ChaCha20.encrypt_and_tag(resp_sub_tlv, hashed_k, "PV-Msg02")

    response = %{
      @kTLVType_State => <<2>>,
      @kTLVType_PublicKey => accessory_epk,
      @kTLVType_EncryptedData => encrypted_data_and_tag
    }

    {:ok, response, %{step: 3, session_key: session_key, ios_epk: ios_epk, accessory_epk: accessory_epk}, nil, nil}
  end

  # Handles `<M3>` messages and returns `<M4>` messages
  def handle_message(%{@kTLVType_State => <<3>>, @kTLVType_EncryptedData => encrypted_data_and_tag}, %{
        step: 3,
        session_key: session_key,
        ios_epk: ios_epk,
        accessory_epk: accessory_epk
      }) do
    with {:ok, hashed_k} <- HKDF.generate(session_key, "Pair-Verify-Encrypt-Salt", "Pair-Verify-Encrypt-Info"),
         {:ok, tlv} <- ChaCha20.decrypt_and_verify(encrypted_data_and_tag, hashed_k, "PV-Msg03"),
         %{@kTLVType_Identifier => ios_identifier, @kTLVType_Signature => ios_signature} <- TLVParser.parse_tlv(tlv),
         ios_device_info <- ios_epk <> ios_identifier <> accessory_epk,
         {ios_ltpk, ios_permissions} <- AccessoryServerManager.controller_pairing(ios_identifier),
         admin? <- ios_permissions == @kFlag_Admin,
         {:ok, true} <- EDDSA.verify(ios_device_info, ios_signature, ios_ltpk),
         {:ok, accessory_to_controller_key} <-
           HKDF.generate(session_key, "Control-Salt", "Control-Read-Encryption-Key"),
         {:ok, controller_to_accessory_key} <-
           HKDF.generate(session_key, "Control-Salt", "Control-Write-Encryption-Key") do
      Logger.info("Verified session for controller #{ios_identifier}")

      {:ok, %{@kTLVType_State => <<4>>}, %{ios_ltpk: ios_ltpk, admin?: admin?}, accessory_to_controller_key,
       controller_to_accessory_key}
    else
      _ ->
        Logger.error("Pair-Verify <M3> Error")

        {:ok, %{@kTLVType_State => <<4>>, @kTLVType_Error => @kTLVError_Authentication},
         %{step: 4, session_key: session_key}, nil, nil}
    end
  end

  def handle_message(tlv, state) do
    Logger.error("Pair-Verify Received unexpected message: #{inspect(tlv)}, state: #{inspect(state)}")

    {:error, "Unexpected message for pairing state"}
  end
end
