defmodule HAP.HTTPServer do
  @moduledoc false
  # Defines the HTTP interface for a HomeKit Accessory

  use Plug.Router

  alias HAP.{CleartextHTTPServer, EncryptedHTTPServer, TLVParser}

  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [TLVParser, :json], json_decoder: Jason)
  plug(:tidy_headers, builder_opts())
  plug(:dispatch, builder_opts())

  def init(opts) do
    opts
  end

  post("/pair-setup", to: CleartextHTTPServer)
  post("/identify", to: CleartextHTTPServer)
  post("/pair-verify", to: CleartextHTTPServer)

  post("/pairings", to: EncryptedHTTPServer)
  get("/accessories", to: EncryptedHTTPServer)
  get("/characteristics", to: EncryptedHTTPServer)
  put("/characteristics", to: EncryptedHTTPServer)

  defp tidy_headers(conn, _opts) do
    delete_resp_header(conn, "cache-control")
  end
end
