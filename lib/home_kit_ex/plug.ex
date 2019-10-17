defmodule HomeKitEx.Plug do
  use Plug.Router

  plug(:match)
  plug(Plug.Parsers, parsers: [HomeKitEx.TLVParser])
  plug(:dispatch)

  def init(options) do
    options
  end

  post "/pair-setup" do
    IO.inspect(conn.body_params)
    send_resp(conn, 200, "OK")
  end

  match _ do
    IO.inspect(conn)
    send_resp(conn, 404, "Not Found")
  end
end
