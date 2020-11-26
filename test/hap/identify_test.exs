defmodule HAP.IdentifyTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  alias HAP.AccessoryServerManager
  alias HAP.Crypto.EDDSA
  alias HAP.Test.{HTTPClient, TestAccessoryServer}

  setup do
    {:ok, _pid} = TestAccessoryServer.test_server() |> start_supervised()

    port = AccessoryServerManager.port()
    {:ok, client} = HTTPClient.init(:localhost, port)

    {:ok, %{client: client}}
  end

  describe "POST /identify" do
    test "it should identify itself", context do
      assert capture_log(fn ->
               {:ok, 204, _headers, _body} = HTTPClient.post(context.client, "/identify", "")
             end) =~ "IDENTIFY Generic HAP Device"
    end

    test "It should not succeed if the accessory is paired", context do
      # Create the pairing as if it already existed
      new_ios_identifier = "BBBBBBBB-CCCC-DDDD-EEEE-FFFFFFFFFFFF"
      {:ok, new_ios_ltpk, _new_ios_ltsk} = EDDSA.key_gen()
      AccessoryServerManager.add_controller_pairing(new_ios_identifier, new_ios_ltpk, <<1>>)

      {:ok, 400, _headers, _body} = HTTPClient.post(context.client, "/identify", "")
    end
  end
end
