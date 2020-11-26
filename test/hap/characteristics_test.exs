defmodule HAP.CharacteristicsTest do
  use ExUnit.Case, async: false

  alias HAP.{AccessoryServerManager, Characteristic, Service}
  alias HAP.Test.{HTTPClient, TestAccessoryServer, TestValueStore}

  setup do
    {:ok, _pid} = start_supervised(TestValueStore)

    {:ok, _pid} =
      [
        accessories: [
          HAP.build_accessory(
            name: "name",
            model: "model",
            manufacturer: "maker",
            serial_number: "123456",
            firmware_revision: "1.0",
            services: [
              %Service{
                type: 12,
                characteristics: [
                  %Characteristic{type: 34, perms: ["pr"], format: "string", value: "abc"},
                  %Characteristic{
                    type: 56,
                    perms: ["pw"],
                    format: "string",
                    value_mod: TestValueStore,
                    value_opts: [label: 56]
                  }
                ]
              }
            ]
          )
        ]
      ]
      |> TestAccessoryServer.test_server()
      |> start_supervised()

    port = AccessoryServerManager.port()
    {:ok, client} = HTTPClient.init(:localhost, port)

    {:ok, %{client: client}}
  end

  describe "GET /characteristics" do
    test "it should return the requested characteristics", context do
      # Setup an encrypted session
      :ok = HTTPClient.setup_encrypted_session(context.client)

      {:ok, 200, headers, body} = HTTPClient.get(context.client, "/characteristics?id=1.3,1.515")

      assert Keyword.get(headers, :"content-type") == "application/hap+json"

      assert Jason.decode!(body) == %{
               "characteristics" => [
                 %{"iid" => 3, "value" => "name", "aid" => 1},
                 %{"iid" => 515, "value" => "1.1.0", "aid" => 1}
               ]
             }
    end

    test "it should require an authenticated session", context do
      {:ok, 401, _headers, _body} = HTTPClient.get(context.client, "/characteristics?id=1.3,1.515")
    end
  end

  describe "PUT /characteristics" do
    test "it should set the requested characteristics", context do
      # Setup an encrypted session
      :ok = HTTPClient.setup_encrypted_session(context.client)

      request = %{
        characteristics: [
          %{"iid" => 1029, "value" => "def", "aid" => 1}
        ]
      }

      {:ok, 204, _headers, _body} =
        HTTPClient.put(context.client, "/characteristics", Jason.encode!(request),
          "content-type": "application/hap+json"
        )

      assert AccessoryServerManager.get_characteristics([%{iid: 1029, aid: 1}]) ==
               %{characteristics: [%{iid: 1029, value: "def", aid: 1}]}
    end

    test "it should require an authenticated session", context do
      request = %{
        characteristics: [
          %{"iid" => 1029, "value" => "def", "aid" => 1}
        ]
      }

      {:ok, 401, _headers, _body} =
        HTTPClient.put(context.client, "/characteristics", Jason.encode!(request),
          "content-type": "application/hap+json"
        )

      refute AccessoryServerManager.get_characteristics([%{iid: 1029, aid: 1}]) ==
               %{characteristics: [%{iid: 1029, value: "def", aid: 1}]}
    end
  end
end
