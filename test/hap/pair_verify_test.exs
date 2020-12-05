defmodule HAP.PairVerifyTest do
  use ExUnit.Case, async: false

  setup do
    {:ok, _pid} = HAP.Test.TestAccessoryServer.test_server() |> start_supervised()

    :ok
  end

  test "a valid pair-verify flow results in a pairing being made" do
    # Build our request parameters
    port = HAP.AccessoryServerManager.port()
    {:ok, client} = HAP.Test.HTTPClient.init(:localhost, port)

    # Ensure that we are not encrypted to start
    refute HAP.Test.HTTPClient.encrypted_session?()

    # Setup an encrypted session
    :ok = HAP.Test.HTTPClient.setup_encrypted_session(client)

    # Finally, ensure that we're working with an encrypted session
    assert HAP.Test.HTTPClient.encrypted_session?()
  end
end
