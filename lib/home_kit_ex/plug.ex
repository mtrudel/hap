defmodule HomeKitEx.Plug do
  use Plug.Router

  alias HomeKitEx.{Accessory, PairSetup, TLVParser, TLVEncoder}

  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [TLVParser])
  plug(:dispatch, builder_opts())

  def init(opts) do
    opts
  end

  post "/pair-setup" do
    conn.body_params
    |> PairSetup.handle_message(Accessory.pairing_state(opts[:accessory]))
    |> case do
      {:ok, response, new_pairing_state} ->
        Accessory.set_pairing_state(opts[:accessory], new_pairing_state)

        conn
        |> put_resp_header("content-type", "application/pairing+tlv8")
        |> send_resp(200, TLVEncoder.to_binary(response))

      {:error, reason} ->
        Accessory.set_pairing_state(opts[:accessory], nil)

        conn
        |> send_resp(400, reason)
    end
  end

  match _ do
    IO.inspect(conn)
    send_resp(conn, 404, "Not Found")
  end
end
