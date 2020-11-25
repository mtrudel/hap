defmodule HAP.HTTPServer do
  @moduledoc """
  Defines the HTTP interface for a HomeKit Accessory
  """

  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [HAP.TLVParser, :json], json_decoder: Jason)
  plug(:tidy_headers, builder_opts())
  plug(:dispatch, builder_opts())

  def init(opts) do
    opts
  end

  post "/identify" do
    if HAP.AccessoryServerManager.paired?() do
      conn
      |> send_resp(400, "Already Paired")
    else
      HAP.AccessoryServerManager.name() |> HAP.Display.identify()

      conn
      |> send_resp(204, "No Content")
    end
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
        HAP.HAPSessionTransport.put_send_key(accessory_to_controller_key)
        HAP.HAPSessionTransport.put_recv_key(controller_to_accessory_key)

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
    if HAP.HAPSessionTransport.encrypted_session?() do
      response = HAP.AccessoryServerManager.get_accessories()

      conn
      |> put_resp_header("content-type", "application/hap+json")
      |> send_resp(200, Jason.encode!(response))
    else
      conn
      |> send_resp(401, "Not Authorized")
    end
  end

  get "/characteristics" do
    response =
      conn.params["id"]
      |> String.split(",")
      |> Enum.map(&String.split(&1, "."))
      |> Enum.map(fn [aid, iid] -> %{aid: String.to_integer(aid), iid: String.to_integer(iid)} end)
      |> HAP.AccessoryServerManager.get_characteristics()

    conn
    |> put_resp_header("content-type", "application/hap+json")
    |> send_resp(200, Jason.encode!(response))
  end

  put "/characteristics" do
    results =
      conn.body_params["characteristics"]
      |> HAP.AccessoryServerManager.put_characteristics()

    if Enum.all?(results, fn {result, _characteristic} -> result == :ok end) do
      conn
      |> put_resp_header("content-type", "application/hap+json")
      |> send_resp(204, "")
    else
      # TODO -- 207 multi

      conn
      |> put_resp_header("content-type", "application/hap+json")
      |> send_resp(204, "No Content")
    end
  end

  defp tidy_headers(conn, _opts) do
    delete_resp_header(conn, "cache-control")
  end
end
