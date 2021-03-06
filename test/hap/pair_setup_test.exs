defmodule HAP.PairSetupTest do
  use ExUnit.Case, async: false

  setup do
    {:ok, _pid} = HAP.Test.TestAccessoryServer.test_server() |> start_supervised()

    :ok
  end

  test "a valid pair-setup flow results in a pairing being made" do
    # A very quick & dirty implementation of the iOS side of the Pair-Setup flow

    # Build our request parameters
    port = HAP.AccessoryServerManager.port()
    {:ok, client} = HAP.Test.HTTPClient.init(:localhost, port)
    endpoint = "/pair-setup"

    # Build M1
    m1 = %{0x06 => <<1>>, 0x00 => <<0>>}

    # Send M1
    {:ok, 200, headers, body} =
      HAP.Test.HTTPClient.post(client, endpoint, HAP.TLVEncoder.to_binary(m1),
        "content-type": "application/pairing+tlv8"
      )

    assert Keyword.get(headers, :"content-type") == "application/pairing+tlv8"

    # Verify M2 & Build M3
    _m2 = %{0x06 => <<2>>, 0x03 => b, 0x02 => salt} = HAP.TLVParser.parse_tlv(body)
    {:ok, auth_context, a} = HAP.Crypto.SRP6A.client("Pair-Setup", HAP.AccessoryServerManager.pairing_code(), salt)
    {:ok, m_1, m_2, session_key} = HAP.Crypto.SRP6A.shared_key(auth_context, b, "Pair-Setup", salt)
    m3 = %{0x06 => <<3>>, 0x03 => a, 0x04 => m_1}

    # Send M3
    {:ok, 200, headers, body} =
      HAP.Test.HTTPClient.post(client, endpoint, HAP.TLVEncoder.to_binary(m3),
        "content-type": "application/pairing+tlv8"
      )

    assert Keyword.get(headers, :"content-type") == "application/pairing+tlv8"

    # Verify M4 & Build M5
    _m4 = %{0x06 => <<4>>, 0x04 => ^m_2} = HAP.TLVParser.parse_tlv(body)
    {:ok, ios_ltpk, ios_ltsk} = HAP.Crypto.EDDSA.key_gen()

    {:ok, ios_device_x} =
      HAP.Crypto.HKDF.generate(session_key, "Pair-Setup-Controller-Sign-Salt", "Pair-Setup-Controller-Sign-Info")

    ios_identifier = "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"
    ios_device_info = ios_device_x <> ios_identifier <> ios_ltpk
    {:ok, ios_signature} = HAP.Crypto.EDDSA.sign(ios_device_info, ios_ltsk)
    sub_tlv = %{0x01 => ios_identifier, 0x03 => ios_ltpk, 0x0A => ios_signature}
    {:ok, envelope_key} = HAP.Crypto.HKDF.generate(session_key, "Pair-Setup-Encrypt-Salt", "Pair-Setup-Encrypt-Info")

    {:ok, encrypted_data_and_tag} =
      HAP.Crypto.ChaCha20.encrypt_and_tag(HAP.TLVEncoder.to_binary(sub_tlv), envelope_key, "PS-Msg05")

    m5 = %{0x06 => <<5>>, 0x05 => encrypted_data_and_tag}

    # Send M5
    {:ok, 200, headers, body} =
      HAP.Test.HTTPClient.post(client, endpoint, HAP.TLVEncoder.to_binary(m5),
        "content-type": "application/pairing+tlv8"
      )

    assert Keyword.get(headers, :"content-type") == "application/pairing+tlv8"

    # Verify M6
    _m6 = %{0x06 => <<6>>, 0x05 => encrypted_data} = HAP.TLVParser.parse_tlv(body)
    {:ok, sub_tlv} = HAP.Crypto.ChaCha20.decrypt_and_verify(encrypted_data, envelope_key, "PS-Msg06")
    accessory_identifier = HAP.AccessoryServerManager.identifier()
    accessory_ltpk = HAP.AccessoryServerManager.ltpk()

    %{0x01 => ^accessory_identifier, 0x03 => ^accessory_ltpk, 0x0A => accessory_signature} =
      HAP.TLVParser.parse_tlv(sub_tlv)

    {:ok, accessory_x} =
      HAP.Crypto.HKDF.generate(session_key, "Pair-Setup-Accessory-Sign-Salt", "Pair-Setup-Accessory-Sign-Info")

    accessory_info = accessory_x <> accessory_identifier <> accessory_ltpk
    {:ok, true} = HAP.Crypto.EDDSA.verify(accessory_info, accessory_signature, accessory_ltpk)

    # Finally, verify that we have successfully paired on the Accessory Server side
    assert HAP.AccessoryServerManager.controller_pairing(ios_identifier) == {ios_ltpk, <<1>>}
  end
end
