defmodule HAP.PairVerify do
  @moduledoc """
  Implements the Pair Verify flow described in Apple's [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/). 
  """

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

  def init do
    %{step: 1}
  end

  # Handles `<M1>` messages and returns `<M2>` messages
  def handle_message(%{@kTLVType_State => <<1>>, @kTLVType_PublicKey => ios_epk}, %{step: 1}) do
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
         %{@kTLVType_Identifier => ios_identifier, @kTLVType_Signature => ios_signature} <-
           HAP.TLVParser.parse_tlv(tlv),
         ios_device_info <- ios_epk <> ios_identifier <> accessory_epk,
         ios_ltpk <- Accessory.get_controller_pairing(ios_identifier),
         {:ok, true} <- HAP.Crypto.EDDSA.verify(ios_device_info, ios_signature, ios_ltpk),
         {:ok, accessory_to_controller_key} = HKDF.generate(session_key, "Control-Salt", "Control-Read-Encryption-Key"),
         {:ok, controller_to_accessory_key} = HKDF.generate(session_key, "Control-Salt", "Control-Write-Encryption-Key") do
      {:ok, %{@kTLVType_State => <<4>>}, %{}, accessory_to_controller_key, controller_to_accessory_key}
    else
      _ ->
        {:ok, %{@kTLVType_State => <<4>>, @kTLVType_Error => @kTLVError_Authentication},
         %{step: 4, session_key: session_key}, nil, nil}
    end
  end

  def handle_message(tlv, state) do
    Logger.error("Received unexpected message for pairing state. Message: #{inspect(tlv)}, state: #{inspect(state)}")
    {:error, "Unexpected message for pairing state"}
  end
end
