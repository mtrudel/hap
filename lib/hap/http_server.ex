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
    with_tlv_handler(conn, HAP.PairSetup)
  end

  post "/pair-verify" do
    with_tlv_handler(conn, HAP.PairVerify)
  end

  match _ do
    IO.inspect(conn)
    send_resp(conn, 404, "Not Found")
  end

  defp tidy_headers(conn, _opts) do
    delete_resp_header(conn, "cache-control")
  end

  defp with_tlv_handler(conn, module) do
    conn.body_params
    |> module.handle_message()
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
end
