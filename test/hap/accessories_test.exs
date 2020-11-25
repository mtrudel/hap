defmodule HAP.AcessoriesTest do
  use ExUnit.Case, async: false

  alias HAP.{AccessoryServerManager, Characteristic, Service}
  alias HAP.Test.{HTTPClient, TestAccessoryServer}

  setup do
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
                  %Characteristic{type: 34, perms: ["pr"], format: "string", value: "abc"}
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

  describe "GET /accessories" do
    test "It should return the expected accessories tree", context do
      # Setup an encrypted session
      :ok = HTTPClient.setup_encrypted_session(context.client)

      {:ok, 200, headers, body} = HTTPClient.get(context.client, "/accessories")

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
                         %{"format" => "string", "iid" => 3, "perms" => ["pr"], "type" => "23", "value" => "name"},
                         %{"format" => "string", "iid" => 5, "perms" => ["pr"], "type" => "21", "value" => "model"},
                         %{"format" => "string", "iid" => 7, "perms" => ["pr"], "type" => "20", "value" => "maker"},
                         %{"format" => "string", "iid" => 9, "perms" => ["pr"], "type" => "30", "value" => "123456"},
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
                       "type" => 12,
                       "characteristics" => [
                         %{"format" => "string", "iid" => 1027, "perms" => ["pr"], "type" => 34, "value" => "abc"}
                       ]
                     }
                   ]
                 }
               ]
             }
    end

    test "It should require an authenticated session", context do
      {:ok, 401, _headers, _body} = HTTPClient.get(context.client, "/accessories")
    end
  end
end
