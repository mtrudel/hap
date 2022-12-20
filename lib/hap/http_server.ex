defmodule HAP.HTTPServer do
  @moduledoc false
  # Defines the HTTP interface for a HomeKit Accessory

  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [HAP.TLVParser, :json], json_decoder: Jason)
  plug(:tidy_headers, builder_opts())
  plug(:dispatch, builder_opts())

  def init(opts) do
    opts
  end

  post("/pair-setup", to: HAP.CleartextHTTPServer)
  post("/identify", to: HAP.CleartextHTTPServer)
  post("/pair-verify", to: HAP.CleartextHTTPServer)

  post("/pairings", to: HAP.EncryptedHTTPServer)
  get("/accessories", to: HAP.EncryptedHTTPServer)
  get("/characteristics", to: HAP.EncryptedHTTPServer)
  put("/characteristics", to: HAP.EncryptedHTTPServer)
  put("/prepare", to: HAP.EncryptedHTTPServer)

  defp tidy_headers(conn, _opts) do
    delete_resp_header(conn, "cache-control")
  end
end
