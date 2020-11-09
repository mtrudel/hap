defmodule HAP.HTTPServer do
  @moduledoc """
  Defines the HTTP interface for a HomeKit Accessory
  """

  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [HAP.TLVParser])
  plug(:tidy_headers, builder_opts())
  plug(:dispatch, builder_opts())

  def init(opts) do
    opts
  end

  post "/pair-setup" do
    conn.body_params
    |> HAP.PairSetup.handle_message()
    |> case do
      {:ok, response} ->
        conn
        |> put_resp_header("content-type", "application/pairing+tlv8")
        |> send_resp(200, HAP.TLVEncoder.to_binary(response))

      {:error, reason} ->
        conn
        |> send_resp(400, reason)
    end
  end

  post "/pair-verify" do
    pair_state = HAP.HAPSessionTransport.get_pair_state()

    HAP.PairVerify.handle_message(conn.body_params, pair_state)
    |> case do
      {:ok, response, new_state, accessory_to_controller_key, controller_to_accessory_key} ->
        conn =
          conn
          |> put_resp_header("content-type", "application/pairing+tlv8")
          |> send_resp(200, HAP.TLVEncoder.to_binary(response))

        HAP.HAPSessionTransport.put_pair_state(new_state)
        HAP.HAPSessionTransport.put_accessory_to_controller_key(accessory_to_controller_key)
        HAP.HAPSessionTransport.put_controller_to_accessory_key(controller_to_accessory_key)

        conn

      {:error, reason} ->
        conn
        |> send_resp(400, reason)
    end
  end

  post "/pairings" do
    pair_state = HAP.HAPSessionTransport.get_pair_state()

    HAP.Pairings.handle_message(conn.body_params, pair_state)
    |> case do
      {:ok, response} ->
        conn
        |> put_resp_header("content-type", "application/pairing+tlv8")
        |> send_resp(200, HAP.TLVEncoder.to_binary(response))

      {:error, reason} ->
        conn
        |> send_resp(400, reason)
    end
  end

  get "/accessories" do
    response = %{
      accessories: [
        %{
          aid: 1,
          services: [
            %{
              type: "3E",
              iid: 1,
              characteristics: [
                %{type: "23", value: "Acme Light Bridge", perms: ["pr"], format: "string", iid: 2},
                %{type: "20", value: "Acme", perms: ["pr"], format: "string", iid: 3},
                %{type: "30", value: "037A2BABF19D", perms: ["pr"], format: "string", iid: 4},
                %{type: "21", value: "Bridge1,1", perms: ["pr"], format: "string", iid: 5},
                %{type: "14", value: nil, perms: ["pr"], format: "bool", iid: 6},
                %{type: "52", value: "100.1.1", perms: ["pr"], format: "string", iid: 7}
              ]
            }
          ]
        }
      ]
    }

    conn
    |> put_resp_header("content-type", "application/hap+json")
    |> send_resp(200, Jason.encode!(response))
  end

  match _ do
    IO.inspect(conn)
    send_resp(conn, 404, "Not Found")
  end

  defp tidy_headers(conn, _opts) do
    delete_resp_header(conn, "cache-control")
  end
end
