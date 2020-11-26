defmodule HAP.PairingsTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  alias HAP.{AccessoryServerManager, TLVEncoder, TLVParser}
  alias HAP.Crypto.EDDSA
  alias HAP.Test.{HTTPClient, TestAccessoryServer}

  setup do
    {:ok, _pid} = TestAccessoryServer.test_server() |> start_supervised()

    # Build our request parameters
    port = AccessoryServerManager.port()
    {:ok, client} = HTTPClient.init(:localhost, port)

    {:ok, %{client: client}}
  end

  describe "Add pairing flow" do
    test "A valid add pairing flow results in a new pairing being added", context do
      # Setup an encrypted session
      :ok = HTTPClient.setup_encrypted_session(context.client)

      endpoint = "/pairings"

      # Build M1
      new_ios_identifier = "BBBBBBBB-CCCC-DDDD-EEEE-FFFFFFFFFFFF"
      {:ok, new_ios_ltpk, _new_ios_ltsk} = EDDSA.key_gen()
      m1 = %{0x06 => <<1>>, 0x00 => <<0x03>>, 0x01 => new_ios_identifier, 0x03 => new_ios_ltpk, 0x0B => <<0x01>>}

      # Send M1
      {:ok, 200, headers, body} =
        HTTPClient.post(context.client, endpoint, TLVEncoder.to_binary(m1), "content-type": "application/pairing+tlv8")

      assert Keyword.get(headers, :"content-type") == "application/pairing+tlv8"

      # Verify M2
      _m2 = %{0x06 => <<2>>} = TLVParser.parse_tlv(body)

      # Finally, verify that we have successfully paired on the Accessory Server side
      assert AccessoryServerManager.controller_pairing(new_ios_identifier) == {new_ios_ltpk, <<1>>}
    end

    test "A valid add pairing flow results in an existing pairing being updated", context do
      # Create the pairing as if it already existed
      new_ios_identifier = "BBBBBBBB-CCCC-DDDD-EEEE-FFFFFFFFFFFF"
      {:ok, new_ios_ltpk, _new_ios_ltsk} = EDDSA.key_gen()
      AccessoryServerManager.add_controller_pairing(new_ios_identifier, new_ios_ltpk, <<1>>)

      # Setup an encrypted session
      :ok = HTTPClient.setup_encrypted_session(context.client)

      endpoint = "/pairings"

      # Build M1 with a new permission
      m1 = %{0x06 => <<1>>, 0x00 => <<0x03>>, 0x01 => new_ios_identifier, 0x03 => new_ios_ltpk, 0x0B => <<0x00>>}

      # Send M1
      {:ok, 200, headers, body} =
        HTTPClient.post(context.client, endpoint, TLVEncoder.to_binary(m1), "content-type": "application/pairing+tlv8")

      assert Keyword.get(headers, :"content-type") == "application/pairing+tlv8"

      # Verify M2
      _m2 = %{0x06 => <<2>>} = TLVParser.parse_tlv(body)

      # Finally, verify that we have successfully updated the pairing on the Accessory Server side
      assert AccessoryServerManager.controller_pairing(new_ios_identifier) == {new_ios_ltpk, <<0>>}
    end

    test "An add pairing flow with an invalid public key fails", context do
      # Create the pairing as if it already existed
      new_ios_identifier = "BBBBBBBB-CCCC-DDDD-EEEE-FFFFFFFFFFFF"
      {:ok, new_ios_ltpk, _new_ios_ltsk} = EDDSA.key_gen()
      AccessoryServerManager.add_controller_pairing(new_ios_identifier, new_ios_ltpk, <<1>>)

      # Setup an encrypted session
      :ok = HTTPClient.setup_encrypted_session(context.client)

      endpoint = "/pairings"

      # Build M1 with a new permission
      {:ok, bogus_ios_ltpk, _new_ios_ltsk} = EDDSA.key_gen()
      m1 = %{0x06 => <<1>>, 0x00 => <<0x03>>, 0x01 => new_ios_identifier, 0x03 => bogus_ios_ltpk, 0x0B => <<0x00>>}

      assert capture_log(fn ->
               # Send M1
               {:ok, 200, headers, body} =
                 HTTPClient.post(context.client, endpoint, TLVEncoder.to_binary(m1),
                   "content-type": "application/pairing+tlv8"
                 )

               assert Keyword.get(headers, :"content-type") == "application/pairing+tlv8"

               # Verify M2
               _m2 = %{0x06 => <<2>>, 0x07 => <<0x01>>} = TLVParser.parse_tlv(body)
             end) =~ "AddPairing <M1> Existing controller LTPK does not match"

      # Finally, verify that we did not update the pairing on the Accessory Server side
      assert AccessoryServerManager.controller_pairing(new_ios_identifier) == {new_ios_ltpk, <<1>>}
    end

    test "An add pairing flow over a non-admin session fails", context do
      # Create the pairing as if it already existed
      new_ios_identifier = "BBBBBBBB-CCCC-DDDD-EEEE-FFFFFFFFFFFF"
      {:ok, new_ios_ltpk, _new_ios_ltsk} = EDDSA.key_gen()
      AccessoryServerManager.add_controller_pairing(new_ios_identifier, new_ios_ltpk, <<1>>)

      # Setup an encrypted session
      :ok = HTTPClient.setup_encrypted_session(context.client, <<0>>)

      endpoint = "/pairings"

      # Build M1 with a new permission
      m1 = %{0x06 => <<1>>, 0x00 => <<0x03>>, 0x01 => new_ios_identifier, 0x03 => new_ios_ltpk, 0x0B => <<0x00>>}

      assert capture_log(fn ->
               # Send M1
               {:ok, 200, headers, body} =
                 HTTPClient.post(context.client, endpoint, TLVEncoder.to_binary(m1),
                   "content-type": "application/pairing+tlv8"
                 )

               assert Keyword.get(headers, :"content-type") == "application/pairing+tlv8"

               # Verify M2
               _m2 = %{0x06 => <<2>>, 0x07 => <<0x02>>} = TLVParser.parse_tlv(body)
             end) =~ "Pairing <M1> Requesting controller is not an admin"

      # Finally, verify that we did not update the pairing on the Accessory Server side
      assert AccessoryServerManager.controller_pairing(new_ios_identifier) == {new_ios_ltpk, <<1>>}
    end

    test "An add pairing flow over a non-authenticated session fails", context do
      # Create the pairing as if it already existed
      new_ios_identifier = "BBBBBBBB-CCCC-DDDD-EEEE-FFFFFFFFFFFF"
      {:ok, new_ios_ltpk, _new_ios_ltsk} = EDDSA.key_gen()
      AccessoryServerManager.add_controller_pairing(new_ios_identifier, new_ios_ltpk, <<1>>)

      endpoint = "/pairings"

      # Build M1 with a new permission
      m1 = %{0x06 => <<1>>, 0x00 => <<0x03>>, 0x01 => new_ios_identifier, 0x03 => new_ios_ltpk, 0x0B => <<0x00>>}

      {:ok, 401, _headers, _body} =
        HTTPClient.post(context.client, endpoint, TLVEncoder.to_binary(m1), "content-type": "application/pairing+tlv8")
    end
  end

  describe "Remove pairing flow" do
    test "A valid remove pairing flow results in pairing being removed", context do
      # Setup an encrypted session
      :ok = HTTPClient.setup_encrypted_session(context.client)

      endpoint = "/pairings"

      # Build M1
      ios_identifier = "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"
      m1 = %{0x06 => <<1>>, 0x00 => <<0x04>>, 0x01 => ios_identifier}

      # Send M1
      {:ok, 200, headers, body} =
        HTTPClient.post(context.client, endpoint, TLVEncoder.to_binary(m1), "content-type": "application/pairing+tlv8")

      assert Keyword.get(headers, :"content-type") == "application/pairing+tlv8"

      # Verify M2
      _m2 = %{0x06 => <<2>>} = TLVParser.parse_tlv(body)

      # Verify that we have successfully removed the pairing on the Accessory Server side
      assert AccessoryServerManager.controller_pairing(ios_identifier) == nil

      # Finally, assert that we are no longer paired
      refute AccessoryServerManager.paired?()
    end

    test "A remove pairing flow over a non-admin session fails", context do
      # Setup an encrypted session
      :ok = HTTPClient.setup_encrypted_session(context.client, <<0>>)

      endpoint = "/pairings"

      # Build M1
      ios_identifier = "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"
      m1 = %{0x06 => <<1>>, 0x00 => <<0x04>>, 0x01 => ios_identifier}

      assert capture_log(fn ->
               # Send M1
               {:ok, 200, headers, body} =
                 HTTPClient.post(context.client, endpoint, TLVEncoder.to_binary(m1),
                   "content-type": "application/pairing+tlv8"
                 )

               assert Keyword.get(headers, :"content-type") == "application/pairing+tlv8"

               # Verify M2
               _m2 = %{0x06 => <<2>>, 0x07 => <<2>>} = TLVParser.parse_tlv(body)
             end) =~ "Pairing <M1> Requesting controller is not an admin"

      # Verify that did not remove the pairing on the Accessory Server side
      refute is_nil(AccessoryServerManager.controller_pairing(ios_identifier))
    end

    test "A remove pairing flow over a non-authenticated session fails", context do
      endpoint = "/pairings"

      # Build M1
      ios_identifier = "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"
      m1 = %{0x06 => <<1>>, 0x00 => <<0x04>>, 0x01 => ios_identifier}

      # Send M1
      {:ok, 401, _headers, _body} =
        HTTPClient.post(context.client, endpoint, TLVEncoder.to_binary(m1), "content-type": "application/pairing+tlv8")
    end
  end

  describe "List pairing flow" do
    test "A valid list pairing flow results in pairings being listed", context do
      # Create the pairing to test multiple listings
      new_ios_identifier = "BBBBBBBB-CCCC-DDDD-EEEE-FFFFFFFFFFFF"
      {:ok, new_ios_ltpk, _new_ios_ltsk} = EDDSA.key_gen()
      AccessoryServerManager.add_controller_pairing(new_ios_identifier, new_ios_ltpk, <<1>>)

      # Setup an encrypted session
      :ok = HTTPClient.setup_encrypted_session(context.client)

      ios_identifier = "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"
      {ios_ltpk, _permissions} = AccessoryServerManager.controller_pairing(ios_identifier)

      endpoint = "/pairings"

      # Build M1
      m1 = %{0x06 => <<1>>, 0x00 => <<0x05>>}

      # Send M1
      {:ok, 200, headers, body} =
        HTTPClient.post(context.client, endpoint, TLVEncoder.to_binary(m1), "content-type": "application/pairing+tlv8")

      assert Keyword.get(headers, :"content-type") == "application/pairing+tlv8"

      # Verify M2
      _m2 =
        [
          "6": <<2>>,
          "1": ^ios_identifier,
          "3": ^ios_ltpk,
          "11": <<1>>,
          "1": ^new_ios_identifier,
          "3": ^new_ios_ltpk,
          "11": <<1>>
        ] = TLVParser.parse_tlv_as_keyword(body)
    end

    test "A list pairing flow over a non-admin session fails", context do
      # Setup an encrypted session
      :ok = HTTPClient.setup_encrypted_session(context.client, <<0>>)

      endpoint = "/pairings"

      # Build M1
      m1 = %{0x06 => <<1>>, 0x00 => <<0x05>>}

      assert capture_log(fn ->
               # Send M1
               {:ok, 200, headers, body} =
                 HTTPClient.post(context.client, endpoint, TLVEncoder.to_binary(m1),
                   "content-type": "application/pairing+tlv8"
                 )

               assert Keyword.get(headers, :"content-type") == "application/pairing+tlv8"

               # Verify M2
               _m2 = %{0x06 => <<2>>, 0x07 => <<2>>} = TLVParser.parse_tlv(body)
             end) =~ "Pairing <M1> Requesting controller is not an admin"
    end

    test "A list pairing flow over a non-authenticated session fails", context do
      endpoint = "/pairings"

      # Build M1
      m1 = %{0x06 => <<1>>, 0x00 => <<0x05>>}

      # Send M1
      {:ok, 401, _headers, _body} =
        HTTPClient.post(context.client, endpoint, TLVEncoder.to_binary(m1), "content-type": "application/pairing+tlv8")
    end
  end
end
