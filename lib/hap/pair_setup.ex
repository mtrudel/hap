defmodule HAP.PairSetup do
  @moduledoc """
  Implements the Pair Setup flow described in Apple's [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/). 
  """

  require Logger

  alias HAP.Crypto.SRP6A

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

  @doc """
  Handles `<M1>` messages and returns `<M2>` messages
  """
  def handle_message(%{@kTLVType_State => <<1>>, @kTLVType_Method => <<0>>}, %HAP.PairingStates.Unpaired{
        username: i,
        pairing_code: p,
        accessory_identifier: accessory_identifier
      }) do
    {s, v} = SRP6A.verifier(i, p)
    {auth_context, b} = SRP6A.auth_context(v)

    response = %{@kTLVType_State => <<2>>, @kTLVType_PublicKey => b, @kTLVType_Salt => s}

    state = %HAP.PairingStates.PairingM2{
      auth_context: auth_context,
      salt: s,
      username: i,
      accessory_identifier: accessory_identifier
    }

    {:ok, response, state}
  end

  def handle_message(%{@kTLVType_State => <<1>>, @kTLVType_Method => <<0>>}, %HAP.PairingStates.Paired{} = state) do
    response = %{@kTLVType_State => <<2>>, @kTLVType_Error => @kTLVError_Unavailable}
    {:ok, response, state}
  end

  def handle_message(%{@kTLVType_State => <<1>>, @kTLVType_Method => <<0>>}, state) do
    response = %{@kTLVType_State => <<2>>, @kTLVType_Error => @kTLVError_Busy}
    {:ok, response, state}
  end

  @doc """
  Handles `<M3>` messages and returns `<M4>` messages
  """
  def handle_message(
        %{@kTLVType_State => <<3>>, @kTLVType_PublicKey => a, @kTLVType_Proof => proof},
        %HAP.PairingStates.PairingM2{
          auth_context: auth_context,
          salt: s,
          username: i,
          accessory_identifier: accessory_identifier
        } = state
      ) do
    {m_1, m_2, k} = SRP6A.shared_key(auth_context, a, i, s)

    if proof == m_1 do
      response = %{@kTLVType_State => <<4>>, @kTLVType_Proof => m_2}
      state = %HAP.PairingStates.PairingM4{session_key: k, accessory_identifier: accessory_identifier}
      {:ok, response, state}
    else
      response = %{@kTLVType_State => <<4>>, @kTLVType_Error => @kTLVError_Authentication}
      {:ok, response, state}
    end
  end

  @doc """
  Handles `<M5>` messages and returns `<M6>` messages
  """
  def handle_message(
        %{@kTLVType_State => <<5>>, @kTLVType_EncryptedData => encrypted_data},
        %HAP.PairingStates.PairingM4{session_key: session_key, accessory_identifier: accessory_identifier} = state
      ) do
    # This is not documented in the spec - taken from HAP-NodeJS's HAPServer.ts
    hashed_k = HKDF.derive(:sha512, session_key, 32, "Pair-Setup-Encrypt-Salt", "Pair-Setup-Encrypt-Info")

    # 5.6.6.1
    encrypted_data_length = byte_size(encrypted_data) - 16
    <<encrypted_data::binary-size(encrypted_data_length), auth_tag::binary-16>> = encrypted_data

    case :crypto.crypto_one_time_aead(:chacha20_poly1305, hashed_k, 'PS-Msg05', encrypted_data, <<>>, auth_tag, false) do
      tlv when is_binary(tlv) ->
        %{
          @kTLVType_Identifier => ios_identifier,
          @kTLVType_PublicKey => ios_ltpk,
          @kTLVType_Signature => ios_signature
        } = tlv |> HAP.TLVParser.parse_tlv()

        ios_device_x =
          HKDF.derive(:sha512, session_key, 32, "Pair-Setup-Controller-Sign-Salt", "Pair-Setup-Controller-Sign-Info")

        ios_device_info = ios_device_x <> ios_identifier <> ios_ltpk
        result = :crypto.verify(:eddsa, :sha512, ios_device_info, ios_signature, [ios_ltpk, :ed25519])

        # TODO - handle this (refactor this whole block into sub-functions)
        IO.puts(result)

        # 5.6.6.2
        {accessory_ltpk, accessory_ltsk} = :crypto.generate_key(:eddsa, :ed25519)

        accessory_x =
          HKDF.derive(:sha512, session_key, 32, "Pair-Setup-Accessory-Sign-Salt", "Pair-Setup-Accessory-Sign-Info")

        accessory_info = accessory_x <> accessory_identifier <> accessory_ltpk
        accessory_signature = :crypto.sign(:eddsa, :sha512, accessory_info, [accessory_ltsk, :ed25519])

        resp_sub_tlv =
          %{
            @kTLVType_Identifier => accessory_identifier,
            @kTLVType_PublicKey => accessory_ltpk,
            @kTLVType_Signature => accessory_signature
          }
          |> HAP.TLVEncoder.to_binary()

        {encrypted_data, auth_tag} =
          :crypto.crypto_one_time_aead(:chacha20_poly1305, hashed_k, 'PS-Msg06', resp_sub_tlv, <<>>, true)

        response = %{
          @kTLVType_State => <<6>>,
          @kTLVType_EncryptedData => encrypted_data <> auth_tag
        }

        state = %HAP.PairingStates.Paired{
          ios_identifier: ios_identifier,
          ios_ltpk: ios_ltpk,
          accessory_identifier: accessory_identifier,
          accessory_ltpk: accessory_ltpk,
          accessory_ltsk: accessory_ltsk
        }

        {:ok, response, state}

      :error ->
        response = %{@kTLVType_State => <<6>>, @kTLVType_Error => @kTLVError_Authentication}
        {:ok, response, state}
    end
  end

  def handle_message(tlv, state) do
    Logger.error("Received unexpected message for pairing state. Message: #{inspect(tlv)}, state: #{inspect(state)}")
    {:error, "Unexpected message for pairing state"}
  end
end
