defmodule HAP.PairSetupTest do
  use ExUnit.Case, async: false

  alias HAP.{AccessoryServerManager, TLVEncoder, TLVParser}
  alias HAP.Crypto.{ChaCha20, EDDSA, HKDF, SRP6A}
  alias HAP.Test.TestAccessoryServer

  setup do
    {:ok, _pid} = TestAccessoryServer.test_server() |> start_supervised()

    :ok
  end

  test "A valid pair-setup flow results in a pairing being made" do
    # A very quick & dirty implementation of the iOS side of the Pair-Setup flow

    port = AccessoryServerManager.port()

    endpoint = %URI{scheme: "http", host: "localhost", port: port, path: "/pair-setup"} |> to_string()

    m1 = %{0x06 => <<1>>, 0x00 => <<0>>}

    {:ok, %HTTPoison.Response{body: body}} =
      HTTPoison.post(endpoint, TLVEncoder.to_binary(m1), "content-type": "application/pairing+tlv8")

    _m2 = %{0x06 => <<2>>, 0x03 => b, 0x02 => salt} = TLVParser.parse_tlv(body)

    {:ok, auth_context, a} = SRP6A.client("Pair-Setup", AccessoryServerManager.pairing_code(), salt)

    {:ok, m_1, m_2, session_key} = SRP6A.shared_key(auth_context, b, "Pair-Setup", salt)

    m3 = %{0x06 => <<3>>, 0x03 => a, 0x04 => m_1}

    {:ok, %HTTPoison.Response{body: body}} =
      HTTPoison.post(endpoint, TLVEncoder.to_binary(m3), "content-type": "application/pairing+tlv8")

    _m4 = %{0x06 => <<4>>, 0x04 => ^m_2} = TLVParser.parse_tlv(body)

    {:ok, ios_ltpk, ios_ltsk} = EDDSA.key_gen()

    {:ok, ios_device_x} =
      HKDF.generate(session_key, "Pair-Setup-Controller-Sign-Salt", "Pair-Setup-Controller-Sign-Info")

    ios_identifier = "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"
    ios_device_info = ios_device_x <> ios_identifier <> ios_ltpk
    {:ok, ios_signature} = EDDSA.sign(ios_device_info, ios_ltsk)

    sub_tlv = %{0x01 => ios_identifier, 0x03 => ios_ltpk, 0x0A => ios_signature}

    {:ok, envelope_key} = HKDF.generate(session_key, "Pair-Setup-Encrypt-Salt", "Pair-Setup-Encrypt-Info")

    {:ok, encrypted_data_and_tag} = ChaCha20.encrypt_and_tag(TLVEncoder.to_binary(sub_tlv), envelope_key, "PS-Msg05")

    m5 = %{0x06 => <<5>>, 0x05 => encrypted_data_and_tag}

    {:ok, %HTTPoison.Response{body: body}} =
      HTTPoison.post(endpoint, TLVEncoder.to_binary(m5), "content-type": "application/pairing+tlv8")

    _m6 = %{0x06 => <<6>>, 0x05 => encrypted_data} = TLVParser.parse_tlv(body)

    {:ok, sub_tlv} = ChaCha20.decrypt_and_verify(encrypted_data, envelope_key, "PS-Msg06")

    accessory_identifier = AccessoryServerManager.identifier()
    accessory_ltpk = AccessoryServerManager.ltpk()

    %{0x01 => ^accessory_identifier, 0x03 => ^accessory_ltpk, 0x0A => accessory_signature} =
      TLVParser.parse_tlv(sub_tlv)

    {:ok, accessory_x} = HKDF.generate(session_key, "Pair-Setup-Accessory-Sign-Salt", "Pair-Setup-Accessory-Sign-Info")

    accessory_info = accessory_x <> accessory_identifier <> accessory_ltpk

    {:ok, true} = EDDSA.verify(accessory_info, accessory_signature, accessory_ltpk)

    assert AccessoryServerManager.controller_pairing(ios_identifier) == {ios_ltpk, <<1>>}
  end
end
