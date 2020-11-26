defmodule HAP.HTTPServer do
  @moduledoc """
  Defines the HTTP interface for a HomeKit Accessory
  """

  use Plug.Router

  alias HAP.{
    AccessoryServerManager,
    Display,
    HAPSessionTransport,
    Pairings,
    PairSetup,
    PairVerify,
    TLVEncoder,
    TLVParser
  }

  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [TLVParser, :json], json_decoder: Jason)
  plug(:tidy_headers, builder_opts())
  plug(:dispatch, builder_opts())

  def init(opts) do
    opts
  end

  post "/identify" do
    if AccessoryServerManager.paired?() do
      conn
      |> send_resp(400, "Already Paired")
    else
      AccessoryServerManager.name() |> Display.identify()

      conn
      |> send_resp(204, "No Content")
    end
  end

  post "/pair-setup" do
    conn.body_params
    |> PairSetup.handle_message()
    |> case do
      {:ok, response} ->
        conn
        |> put_resp_header("content-type", "application/pairing+tlv8")
        |> send_resp(200, TLVEncoder.to_binary(response))

      {:error, reason} ->
        conn
        |> send_resp(400, reason)
    end
  end

  post "/pair-verify" do
    pair_state = HAPSessionTransport.get_pair_state()

    PairVerify.handle_message(conn.body_params, pair_state)
    |> case do
      {:ok, response, new_state, accessory_to_controller_key, controller_to_accessory_key} ->
        conn =
          conn
          |> put_resp_header("content-type", "application/pairing+tlv8")
          |> send_resp(200, TLVEncoder.to_binary(response))

        HAPSessionTransport.put_pair_state(new_state)
        HAPSessionTransport.put_send_key(accessory_to_controller_key)
        HAPSessionTransport.put_recv_key(controller_to_accessory_key)

        conn

      {:error, reason} ->
        conn
        |> send_resp(400, reason)
    end
  end

  post "/pairings" do
    if HAPSessionTransport.encrypted_session?() do
      pair_state = HAPSessionTransport.get_pair_state()

      Pairings.handle_message(conn.body_params, pair_state)
      |> case do
        {:ok, response} ->
          conn
          |> put_resp_header("content-type", "application/pairing+tlv8")
          |> send_resp(200, TLVEncoder.to_binary(response))

        {:error, reason} ->
          conn
          |> send_resp(400, reason)
      end
    else
      conn
      |> send_resp(401, "Not Authorized")
    end
  end

  get "/accessories" do
    if HAPSessionTransport.encrypted_session?() do
      response = AccessoryServerManager.get_accessories()

      conn
      |> put_resp_header("content-type", "application/hap+json")
      |> send_resp(200, Jason.encode!(response))
    else
      conn
      |> send_resp(401, "Not Authorized")
    end
  end

  get "/characteristics" do
    if HAPSessionTransport.encrypted_session?() do
      response =
        conn.params["id"]
        |> String.split(",")
        |> Enum.map(&String.split(&1, "."))
        |> Enum.map(fn [aid, iid] -> %{aid: String.to_integer(aid), iid: String.to_integer(iid)} end)
        |> AccessoryServerManager.get_characteristics()

      conn
      |> put_resp_header("content-type", "application/hap+json")
      |> send_resp(200, Jason.encode!(response))
    else
      conn
      |> send_resp(401, "Not Authorized")
    end
  end

  put "/characteristics" do
    results =
      conn.body_params["characteristics"]
      |> AccessoryServerManager.put_characteristics()

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
