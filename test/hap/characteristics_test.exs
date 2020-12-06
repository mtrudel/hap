defmodule HAP.CharacteristicsTest do
  use ExUnit.Case, async: false

  setup do
    {:ok, _pid} = start_supervised(HAP.Test.TestValueStore)

    {:ok, _pid} =
      [
        accessories: [
          %HAP.Accessory{
            services: [
              %HAP.Services.LightBulb{on: {HAP.Test.TestValueStore, value_name: :lightbulb}}
            ]
          }
        ]
      ]
      |> HAP.Test.TestAccessoryServer.test_server()
      |> start_supervised()

    port = HAP.AccessoryServerManager.port()
    {:ok, client} = HAP.Test.HTTPClient.init(:localhost, port)

    {:ok, %{client: client}}
  end

  describe "GET /characteristics" do
    test "it should return the requested characteristics", context do
      # Setup an encrypted session
      :ok = HAP.Test.HTTPClient.setup_encrypted_session(context.client)

      {:ok, 200, headers, body} = HAP.Test.HTTPClient.get(context.client, "/characteristics?id=1.3,1.515")

      assert Keyword.get(headers, :"content-type") == "application/hap+json"

      assert Jason.decode!(body) == %{
               "characteristics" => [
                 %{"iid" => 3, "value" => "Generic HAP Accessory", "aid" => 1},
                 %{"iid" => 515, "value" => "1.1.0", "aid" => 1}
               ]
             }
    end

    test "it should require an authenticated session", context do
      {:ok, 401, _headers, _body} = HAP.Test.HTTPClient.get(context.client, "/characteristics?id=1.3,1.515")
    end
  end

  describe "PUT /characteristics" do
    test "it should set the requested characteristics", context do
      # Setup an encrypted session
      :ok = HAP.Test.HTTPClient.setup_encrypted_session(context.client)

      request = %{
        characteristics: [
          %{"iid" => 1027, "value" => true, "aid" => 1}
        ]
      }

      {:ok, 204, _headers, _body} =
        HAP.Test.HTTPClient.put(context.client, "/characteristics", Jason.encode!(request),
          "content-type": "application/hap+json"
        )

      assert HAP.AccessoryServerManager.get_characteristics([%{iid: 1027, aid: 1}]) ==
               %{characteristics: [%{iid: 1027, value: true, aid: 1}]}
    end

    test "it should require an authenticated session", context do
      request = %{
        characteristics: [
          %{"iid" => 1027, "value" => true, "aid" => 1}
        ]
      }

      {:ok, 401, _headers, _body} =
        HAP.Test.HTTPClient.put(context.client, "/characteristics", Jason.encode!(request),
          "content-type": "application/hap+json"
        )

      refute HAP.AccessoryServerManager.get_characteristics([%{iid: 1027, aid: 1}]) ==
               %{characteristics: [%{iid: 1027, value: true, aid: 1}]}
    end
  end
end
