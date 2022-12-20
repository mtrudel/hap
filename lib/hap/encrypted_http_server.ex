defmodule HAP.EncryptedHTTPServer do
  @moduledoc false
  # Defines the HTTP interface for a HomeKit Accessory which may only be accessed over a secure channel

  use Plug.Router

  plug(:match)
  plug(:require_authenticated_session, builder_opts())
  plug(:dispatch, builder_opts())

  def init(opts) do
    opts
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
    response = HAP.AccessoryServerManager.get_accessories()

    conn
    |> put_resp_header("content-type", "application/hap+json")
    |> send_resp(200, Jason.encode!(response))
  end

  get "/characteristics" do
    opts =
      conn.params
      |> Map.take(~w[meta perms type ev])
      |> Enum.filter(fn {_k, v} -> v == "1" end)
      |> Enum.map(fn {k, _v} -> String.to_atom(k) end)

    characteristics =
      conn.params["id"]
      |> String.split(",")
      |> Enum.map(&String.split(&1, "."))
      |> Enum.map(fn [aid, iid] -> %{aid: String.to_integer(aid), iid: String.to_integer(iid)} end)
      |> HAP.AccessoryServerManager.get_characteristics(opts)

    if Enum.all?(characteristics, fn %{status: status} -> status == 0 end) do
      characteristics = characteristics |> Enum.map(fn characteristic -> characteristic |> Map.delete(:status) end)

      conn
      |> put_resp_header("content-type", "application/hap+json")
      |> send_resp(200, Jason.encode!(%{characteristics: characteristics}))
    else
      conn
      |> put_resp_header("content-type", "application/hap+json")
      |> send_resp(207, Jason.encode!(%{characteristics: characteristics}))
    end
  end

  put "/characteristics" do
    characteristics =
      conn.body_params["characteristics"]
      |> HAP.AccessoryServerManager.put_characteristics()

    all_success = Enum.all?(characteristics, fn %{status: status} -> status == 0 end)
    no_values = Enum.all?(characteristics, fn result -> !Map.has_key?(result, :value) end)

    if all_success && no_values do
      conn
      |> put_resp_header("content-type", "application/hap+json")
      |> send_resp(204, "")
    else
      conn
      |> put_resp_header("content-type", "application/hap+json")
      |> send_resp(207, Jason.encode!(%{characteristics: characteristics}))
    end
  end

  # Note that we do not enforce timed writes per 6.7.2.4; we just throw this request on the ground
  put "/prepare" do
    conn
    |> put_resp_header("content-type", "application/hap+json")
    |> send_resp(200, Jason.encode!(%{status: 0}))
  end

  defp require_authenticated_session(conn, _opts) do
    if HAP.HAPSessionTransport.encrypted_session?() do
      conn
    else
      conn
      |> send_resp(401, "Not Authorized")
      |> halt()
    end
  end
end
