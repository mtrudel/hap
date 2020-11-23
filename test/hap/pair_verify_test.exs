defmodule HAP.PairVerifyTest do
  use ExUnit.Case, async: false

  alias HAP.Test.HTTPClient

  setup do
    {:ok, _pid} = HAP.Test.TestAccessoryServer.test_server() |> start_supervised()

    :ok
  end

  test "A valid pair-verify flow results in a pairing being made" do
    # Set ourselves up as if we'd already set up a pairing
    ios_identifier = "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"
    {:ok, ios_ltpk, ios_ltsk} = HAP.Crypto.EDDSA.key_gen()
    HAP.AccessoryServerManager.add_controller_pairing(ios_identifier, ios_ltpk, <<1>>)

    # A very quick & dirty implementation of the iOS side of the Pair-Verify flow

    port = HAP.AccessoryServerManager.port()
    {:ok, client} = HTTPClient.init(:localhost, port)

    endpoint = "/pair-verify"

    {:ok, ios_epk, ios_esk} = HAP.Crypto.ECDH.key_gen()

    m1 = %{0x06 => <<1>>, 0x03 => ios_epk}

    {:ok, 200, headers, body} =
      HTTPClient.post(client, endpoint, HAP.TLVEncoder.to_binary(m1), "content-type": "application/pairing+tlv8")

    assert Keyword.get(headers, :"content-type") == "application/pairing+tlv8"

    _m2 = %{0x06 => <<2>>, 0x03 => accessory_epk, 0x05 => encrypted_data} = HAP.TLVParser.parse_tlv(body)

    {:ok, session_key} = HAP.Crypto.ECDH.compute_key(accessory_epk, ios_esk)

    {:ok, envelope_key} = HAP.Crypto.HKDF.generate(session_key, "Pair-Verify-Encrypt-Salt", "Pair-Verify-Encrypt-Info")

    {:ok, sub_tlv} = HAP.Crypto.ChaCha20.decrypt_and_verify(encrypted_data, envelope_key, "PV-Msg02")

    accessory_identifier = HAP.AccessoryServerManager.identifier()

    %{0x01 => ^accessory_identifier, 0x0A => accessory_signature} = HAP.TLVParser.parse_tlv(sub_tlv)

    accessory_device_info = accessory_epk <> accessory_identifier <> ios_epk
    accessory_ltpk = HAP.AccessoryServerManager.ltpk()

    {:ok, true} = HAP.Crypto.EDDSA.verify(accessory_device_info, accessory_signature, accessory_ltpk)

    ios_device_info = ios_epk <> ios_identifier <> accessory_epk

    {:ok, ios_signature} = HAP.Crypto.EDDSA.sign(ios_device_info, ios_ltsk)

    sub_tlv = %{0x01 => ios_identifier, 0x0A => ios_signature}

    {:ok, encrypted_data_and_tag} =
      HAP.Crypto.ChaCha20.encrypt_and_tag(HAP.TLVEncoder.to_binary(sub_tlv), envelope_key, "PV-Msg03")

    m3 = %{0x06 => <<3>>, 0x05 => encrypted_data_and_tag}

    {:ok, 200, headers, body} =
      HTTPClient.post(client, endpoint, HAP.TLVEncoder.to_binary(m3), "content-type": "application/pairing+tlv8")

    assert Keyword.get(headers, :"content-type") == "application/pairing+tlv8"

    _m4 = %{0x06 => <<4>>} = HAP.TLVParser.parse_tlv(body)

    {:ok, accessory_to_controller_key} =
      HAP.Crypto.HKDF.generate(session_key, "Control-Salt", "Control-Read-Encryption-Key")

    {:ok, controller_to_accessory_key} =
      HAP.Crypto.HKDF.generate(session_key, "Control-Salt", "Control-Write-Encryption-Key")

    # Note that these are reversed since we're acting as the controller here
    HAP.HAPSessionTransport.put_accessory_to_controller_key(controller_to_accessory_key)
    HAP.HAPSessionTransport.put_controller_to_accessory_key(accessory_to_controller_key)

    # This ensures that we're working with an encrypted session
    {:ok, 200, _headers, _body} = HTTPClient.get(client, "/accessories", "content-type": "application/hap+json")
  end
end
