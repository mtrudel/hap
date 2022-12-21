defmodule HAP.CharacteristicsTest do
  use ExUnit.Case, async: false

  setup do
    {:ok, _pid} = start_supervised(HAP.Test.TestValueStore)

    {:ok, _pid} =
      [
        accessories: [
          %HAP.Accessory{
            services: [
              %HAP.Services.LightBulb{
                on: {HAP.Test.TestValueStore, value_name: :lightbulb},
                brightness: {HAP.Test.TestValueStore, value_name: :brightness}
              }
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

    test "it should return requested characteristics if some are invalid reads", context do
      # Setup an encrypted session
      :ok = HAP.Test.HTTPClient.setup_encrypted_session(context.client)

      {:ok, 207, headers, body} = HAP.Test.HTTPClient.get(context.client, "/characteristics?id=1.3,1.13")

      assert Keyword.get(headers, :"content-type") == "application/hap+json"

      assert Jason.decode!(body) == %{
               "characteristics" => [
                 %{"iid" => 3, "value" => "Generic HAP Accessory", "aid" => 1, "status" => 0},
                 %{"iid" => 13, "aid" => 1, "status" => -70_405}
               ]
             }
    end

    test "it should return requested characteristics if some are invalid iids", context do
      # Setup an encrypted session
      :ok = HAP.Test.HTTPClient.setup_encrypted_session(context.client)

      {:ok, 207, headers, body} = HAP.Test.HTTPClient.get(context.client, "/characteristics?id=1.3,1.9999999")

      assert Keyword.get(headers, :"content-type") == "application/hap+json"

      assert Jason.decode!(body) == %{
               "characteristics" => [
                 %{"iid" => 3, "value" => "Generic HAP Accessory", "aid" => 1, "status" => 0},
                 %{"iid" => 9_999_999, "aid" => 1, "status" => -70_409}
               ]
             }
    end

    test "it should return permissions when requested", context do
      # Setup an encrypted session
      :ok = HAP.Test.HTTPClient.setup_encrypted_session(context.client)

      {:ok, 200, headers, body} = HAP.Test.HTTPClient.get(context.client, "/characteristics?id=1.3,1.515&perms=1")

      assert Keyword.get(headers, :"content-type") == "application/hap+json"

      assert Jason.decode!(body) == %{
               "characteristics" => [
                 %{"iid" => 3, "value" => "Generic HAP Accessory", "aid" => 1, "perms" => ["pr"]},
                 %{"iid" => 515, "value" => "1.1.0", "aid" => 1, "perms" => ["pr"]}
               ]
             }
    end

    test "it should return type when requested", context do
      # Setup an encrypted session
      :ok = HAP.Test.HTTPClient.setup_encrypted_session(context.client)

      {:ok, 200, headers, body} = HAP.Test.HTTPClient.get(context.client, "/characteristics?id=1.3,1.515&type=1")

      assert Keyword.get(headers, :"content-type") == "application/hap+json"

      assert Jason.decode!(body) == %{
               "characteristics" => [
                 %{"iid" => 3, "value" => "Generic HAP Accessory", "aid" => 1, "type" => "23"},
                 %{"iid" => 515, "value" => "1.1.0", "aid" => 1, "type" => "37"}
               ]
             }
    end

    test "it should return meta when requested", context do
      # Setup an encrypted session
      :ok = HAP.Test.HTTPClient.setup_encrypted_session(context.client)

      {:ok, 200, headers, body} = HAP.Test.HTTPClient.get(context.client, "/characteristics?id=1.3,1.515&meta=1")

      assert Keyword.get(headers, :"content-type") == "application/hap+json"

      assert Jason.decode!(body) == %{
               "characteristics" => [
                 %{"iid" => 3, "value" => "Generic HAP Accessory", "aid" => 1, "format" => "string", "maxLength" => 64},
                 %{"iid" => 515, "value" => "1.1.0", "aid" => 1, "format" => "string", "maxLength" => 64}
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

      assert HAP.AccessoryServerManager.get_characteristics([%{iid: 1027, aid: 1}], :pr) ==
               [%{iid: 1027, value: true, aid: 1, status: 0}]
    end

    test "it should translate 0 and 1 to boolean values on boolean characteristics", context do
      # Setup an encrypted session
      :ok = HAP.Test.HTTPClient.setup_encrypted_session(context.client)

      request = %{
        characteristics: [
          %{"iid" => 1027, "value" => 1, "aid" => 1}
        ]
      }

      {:ok, 204, _headers, _body} =
        HAP.Test.HTTPClient.put(context.client, "/characteristics", Jason.encode!(request),
          "content-type": "application/hap+json"
        )

      assert HAP.AccessoryServerManager.get_characteristics([%{iid: 1027, aid: 1}], :pr) ==
               [%{iid: 1027, value: true, aid: 1, status: 0}]

      request = %{
        characteristics: [
          %{"iid" => 1027, "value" => 0, "aid" => 1}
        ]
      }

      {:ok, 204, _headers, _body} =
        HAP.Test.HTTPClient.put(context.client, "/characteristics", Jason.encode!(request),
          "content-type": "application/hap+json"
        )

      assert HAP.AccessoryServerManager.get_characteristics([%{iid: 1027, aid: 1}], :pr) ==
               [%{iid: 1027, value: false, aid: 1, status: 0}]
    end

    test "it should not translate non-boolean values", context do
      # Setup an encrypted session
      :ok = HAP.Test.HTTPClient.setup_encrypted_session(context.client)

      request = %{
        characteristics: [
          %{"iid" => 1029, "value" => 1, "aid" => 1}
        ]
      }

      {:ok, 204, _headers, _body} =
        HAP.Test.HTTPClient.put(context.client, "/characteristics", Jason.encode!(request),
          "content-type": "application/hap+json"
        )

      assert HAP.AccessoryServerManager.get_characteristics([%{iid: 1029, aid: 1}], :pr) ==
               [%{iid: 1029, value: 1, aid: 1, status: 0}]

      request = %{
        characteristics: [
          %{"iid" => 1029, "value" => 0, "aid" => 1}
        ]
      }

      {:ok, 204, _headers, _body} =
        HAP.Test.HTTPClient.put(context.client, "/characteristics", Jason.encode!(request),
          "content-type": "application/hap+json"
        )

      assert HAP.AccessoryServerManager.get_characteristics([%{iid: 1029, aid: 1}], :pr) ==
               [%{iid: 1029, value: 0, aid: 1, status: 0}]
    end

    test "it should set the requested characteristics even if some are invalid writes", context do
      # Setup an encrypted session
      :ok = HAP.Test.HTTPClient.setup_encrypted_session(context.client)

      request = %{
        characteristics: [
          %{"iid" => 1027, "value" => true, "aid" => 1},
          %{"iid" => 3, "value" => "new name", "aid" => 1}
        ]
      }

      {:ok, 207, headers, body} =
        HAP.Test.HTTPClient.put(context.client, "/characteristics", Jason.encode!(request),
          "content-type": "application/hap+json"
        )

      assert Keyword.get(headers, :"content-type") == "application/hap+json"

      assert Jason.decode!(body) == %{
               "characteristics" => [
                 %{"iid" => 1027, "aid" => 1, "status" => 0},
                 %{"iid" => 3, "aid" => 1, "status" => -70_404}
               ]
             }

      assert HAP.AccessoryServerManager.get_characteristics([%{iid: 1027, aid: 1}], :pr) ==
               [%{iid: 1027, value: true, aid: 1, status: 0}]
    end

    test "it should set the requested characteristics even if some are invalid iids", context do
      # Setup an encrypted session
      :ok = HAP.Test.HTTPClient.setup_encrypted_session(context.client)

      request = %{
        characteristics: [
          %{"iid" => 1027, "value" => true, "aid" => 1},
          %{"iid" => 9_999_999, "value" => "new", "aid" => 1}
        ]
      }

      {:ok, 207, headers, body} =
        HAP.Test.HTTPClient.put(context.client, "/characteristics", Jason.encode!(request),
          "content-type": "application/hap+json"
        )

      assert Keyword.get(headers, :"content-type") == "application/hap+json"

      assert Jason.decode!(body) == %{
               "characteristics" => [
                 %{"iid" => 1027, "aid" => 1, "status" => 0},
                 %{"iid" => 9_999_999, "aid" => 1, "status" => -70_409}
               ]
             }

      assert HAP.AccessoryServerManager.get_characteristics([%{iid: 1027, aid: 1}], :pr) ==
               [%{iid: 1027, value: true, aid: 1, status: 0}]
    end

    test "it should return the requested characteristics values when requested", context do
      # Setup an encrypted session
      :ok = HAP.Test.HTTPClient.setup_encrypted_session(context.client)

      request = %{
        characteristics: [
          %{"iid" => 1027, "value" => true, "aid" => 1, "r" => true}
        ]
      }

      {:ok, 207, headers, body} =
        HAP.Test.HTTPClient.put(context.client, "/characteristics", Jason.encode!(request),
          "content-type": "application/hap+json"
        )

      assert Keyword.get(headers, :"content-type") == "application/hap+json"

      assert Jason.decode!(body) == %{
               "characteristics" => [
                 %{"iid" => 1027, "aid" => 1, "status" => 0, "value" => true}
               ]
             }
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

      refute HAP.AccessoryServerManager.get_characteristics([%{iid: 1027, aid: 1}], :pr) ==
               %{characteristics: [%{iid: 1027, value: true, aid: 1}]}
    end

    test "it should support timed writes (ignoring timeouts)", context do
      # Setup an encrypted session
      :ok = HAP.Test.HTTPClient.setup_encrypted_session(context.client)

      request = %{"ttl" => 5000, "pid" => 123_456_789}

      {:ok, 200, _headers, body} =
        HAP.Test.HTTPClient.put(context.client, "/prepare", Jason.encode!(request),
          "content-type": "application/hap+json"
        )

      assert Jason.decode!(body) == %{"status" => 0}

      request = %{
        characteristics: [
          %{"iid" => 1027, "value" => true, "aid" => 1}
        ],
        pid: 123_456_789
      }

      {:ok, 204, _headers, _body} =
        HAP.Test.HTTPClient.put(context.client, "/characteristics", Jason.encode!(request),
          "content-type": "application/hap+json"
        )

      assert HAP.AccessoryServerManager.get_characteristics([%{iid: 1027, aid: 1}], :pr) ==
               [%{iid: 1027, value: true, aid: 1, status: 0}]
    end
  end
end
