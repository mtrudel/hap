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
    connection_state = Process.get(:hap_connection_info, HAP.PairVerify.init())

    HAP.PairVerify.handle_message(conn.body_params, connection_state)
    |> case do
      {:ok, response, new_state, accessory_to_controller_key, controller_to_accessory_key} ->
        conn =
          conn
          |> put_resp_header("content-type", "application/pairing+tlv8")
          |> send_resp(200, HAP.TLVEncoder.to_binary(response))

        Process.put(:hap_connection_info, new_state)
        Process.put(:accessory_to_controller_key, accessory_to_controller_key)
        Process.put(:controller_to_accessory_key, controller_to_accessory_key)

        conn

      {:error, reason} ->
        conn
        |> send_resp(400, reason)
    end
  end

  match _ do
    IO.inspect(conn)
    send_resp(conn, 404, "Not Found")
  end

  defp tidy_headers(conn, _opts) do
    delete_resp_header(conn, "cache-control")
  end
end
