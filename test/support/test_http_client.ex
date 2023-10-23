defmodule HAP.Test.HTTPClient do
  @moduledoc """
  A super simple HTTP client that knows how to speak HAP encrypted sessions. Not
  even remotely generally compliant.
  """

  def init(host, port) do
    :gen_tcp.connect(host, port, mode: :binary, active: false)
  end

  def get(socket, path, headers \\ []) do
    request(socket, "GET", path, "", headers)
  end

  def put(socket, path, body, headers \\ []) do
    request(socket, "PUT", path, body, headers)
  end

  def post(socket, path, body, headers \\ []) do
    request(socket, "POST", path, body, headers)
  end

  def request(socket, method, path, body, headers) do
    {:ok, {_ip, port}} = HAP.HAPSessionTransport.sockname(socket)

    request = [
      "#{method} #{path} HTTP/1.1\r\n",
      Enum.map(headers, fn {k, v} -> "#{k}: #{v}\r\n" end),
      ["connection: keep-alive\r\n"],
      ["host: localhost:#{port}\r\n"],
      ["content-length: #{byte_size(body)}\r\n"],
      "\r\n",
      body
    ]

    HAP.HAPSessionTransport.send(socket, request)
    {:ok, result} = HAP.HAPSessionTransport.recv(socket, 0, :infinity)

    ["HTTP/1.1" <> code | lines] = result |> String.split("\r\n")

    {code, _text} = code |> String.trim() |> Integer.parse()

    {headers, [_ | body]} =
      lines
      |> Enum.split_while(fn line -> line != "" end)

    headers =
      headers
      |> Enum.map(fn header ->
        [k, v] = header |> String.split(":", parts: 2)
        {k |> String.trim() |> String.to_atom(), String.trim(v)}
      end)

    {:ok, code, headers, IO.iodata_to_binary(body)}
  end

  defdelegate encrypted_session?, to: HAP.HAPSessionTransport

  def setup_encrypted_session(client, permissions \\ <<1>>) do
    # Set ourselves up as if we'd already set up a pairing
    ios_identifier = "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"
    {:ok, ios_ltpk, ios_ltsk} = HAP.Crypto.EDDSA.key_gen()
    HAP.AccessoryServerManager.add_controller_pairing(ios_identifier, ios_ltpk, permissions)

    # A very quick & dirty implementation of the iOS side of the Pair-Verify flow
    #
    endpoint = "/pair-verify"

    # Build M1
    {:ok, ios_epk, ios_esk} = HAP.Crypto.ECDH.key_gen()
    m1 = %{0x06 => <<1>>, 0x03 => ios_epk}

    # Send M1
    {:ok, 200, headers, body} =
      post(client, endpoint, HAP.TLVEncoder.to_binary(m1), "content-type": "application/pairing+tlv8")

    "application/pairing+tlv8" = Keyword.get(headers, :"content-type")

    # Verify M2 & Build M3
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

    # Send M3
    {:ok, 200, headers, body} =
      post(client, endpoint, HAP.TLVEncoder.to_binary(m3), "content-type": "application/pairing+tlv8")

    "application/pairing+tlv8" = Keyword.get(headers, :"content-type")

    # Verify M4
    _m4 = %{0x06 => <<4>>} = HAP.TLVParser.parse_tlv(body)

    {:ok, accessory_to_controller_key} =
      HAP.Crypto.HKDF.generate(session_key, "Control-Salt", "Control-Read-Encryption-Key")

    {:ok, controller_to_accessory_key} =
      HAP.Crypto.HKDF.generate(session_key, "Control-Salt", "Control-Write-Encryption-Key")

    # Note that these are reversed since we're acting as the controller here
    HAP.HAPSessionTransport.put_send_key(controller_to_accessory_key)
    HAP.HAPSessionTransport.put_recv_key(accessory_to_controller_key)

    :ok
  end
end
