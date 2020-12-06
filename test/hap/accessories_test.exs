defmodule HAP.AcessoriesTest do
  use ExUnit.Case, async: false

  setup do
    {:ok, _pid} = start_supervised(HAP.Test.TestValueStore)
    HAP.Test.TestValueStore.put_value(true, value_name: :lightbulb)

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

  describe "GET /accessories" do
    test "it should return the expected accessories tree", context do
      # Setup an encrypted session
      :ok = HAP.Test.HTTPClient.setup_encrypted_session(context.client)

      {:ok, 200, headers, body} = HAP.Test.HTTPClient.get(context.client, "/accessories")

      assert Keyword.get(headers, :"content-type") == "application/hap+json"

      assert Jason.decode!(body) == %{
               "accessories" => [
                 %{
                   "aid" => 1,
                   "services" => [
                     %{
                       "iid" => 1,
                       "type" => "3E",
                       "characteristics" => [
                         %{
                           "format" => "string",
                           "iid" => 3,
                           "perms" => ["pr"],
                           "type" => "23",
                           "value" => "Generic HAP Accessory"
                         },
                         %{
                           "format" => "string",
                           "iid" => 5,
                           "perms" => ["pr"],
                           "type" => "21",
                           "value" => "Generic HAP Model"
                         },
                         %{
                           "format" => "string",
                           "iid" => 7,
                           "perms" => ["pr"],
                           "type" => "20",
                           "value" => "Generic HAP Manufacturer"
                         },
                         %{
                           "format" => "string",
                           "iid" => 9,
                           "perms" => ["pr"],
                           "type" => "30",
                           "value" => "Generic Serial Number"
                         },
                         %{"format" => "string", "iid" => 11, "perms" => ["pr"], "type" => "52", "value" => "1.0"},
                         %{"format" => "bool", "iid" => 13, "perms" => ["pw"], "type" => "14"}
                       ]
                     },
                     %{
                       "iid" => 513,
                       "type" => "A2",
                       "characteristics" => [
                         %{"format" => "string", "iid" => 515, "perms" => ["pr"], "type" => "37", "value" => "1.1.0"}
                       ]
                     },
                     %{
                       "iid" => 1025,
                       "type" => "43",
                       "characteristics" => [
                         %{
                           "format" => "bool",
                           "iid" => 1027,
                           "perms" => ["pr", "pw", "ev"],
                           "type" => "25",
                           "value" => true
                         }
                       ]
                     }
                   ]
                 }
               ]
             }
    end

    test "it should require an authenticated session", context do
      {:ok, 401, _headers, _body} = HAP.Test.HTTPClient.get(context.client, "/accessories")
    end
  end
end
