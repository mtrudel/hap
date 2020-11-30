defmodule HAP.EncryptedHTTPServer do
  @moduledoc false
  # Defines the HTTP interface for a HomeKit Accessory which may only be 
  # accessed over a secure channel

  use Plug.Router

  alias HAP.{AccessoryServerManager, HAPSessionTransport, Pairings, TLVEncoder}

  plug(:match)
  plug(:require_authenticated_session, builder_opts())
  plug(:dispatch, builder_opts())

  def init(opts) do
    opts
  end

  post "/pairings" do
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
  end

  get "/accessories" do
    response = AccessoryServerManager.get_accessories()

    conn
    |> put_resp_header("content-type", "application/hap+json")
    |> send_resp(200, Jason.encode!(response))
  end

  get "/characteristics" do
    response =
      conn.params["id"]
      |> String.split(",")
      |> Enum.map(&String.split(&1, "."))
      |> Enum.map(fn [aid, iid] -> %{aid: String.to_integer(aid), iid: String.to_integer(iid)} end)
      |> AccessoryServerManager.get_characteristics()

    conn
    |> put_resp_header("content-type", "application/hap+json")
    |> send_resp(200, Jason.encode!(response))
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

  defp require_authenticated_session(conn, _opts) do
    if HAPSessionTransport.encrypted_session?() do
      conn
    else
      conn
      |> send_resp(401, "Not Authorized")
      |> halt()
    end
  end
end
