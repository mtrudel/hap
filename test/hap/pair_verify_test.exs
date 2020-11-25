defmodule HAP.PairVerifyTest do
  use ExUnit.Case, async: false

  alias HAP.AccessoryServerManager
  alias HAP.Test.{HTTPClient, TestAccessoryServer}

  setup do
    {:ok, _pid} = TestAccessoryServer.test_server() |> start_supervised()

    :ok
  end

  test "A valid pair-verify flow results in a pairing being made" do
    # Build our request parameters
    port = AccessoryServerManager.port()
    {:ok, client} = HTTPClient.init(:localhost, port)

    # Ensure that we are not encrypted to start
    refute HTTPClient.encrypted_session?()

    # Setup an encrypted session
    :ok = HTTPClient.setup_encrypted_session(client)

    # Finally, ensure that we're working with an encrypted session
    assert HTTPClient.encrypted_session?()
  end
end
