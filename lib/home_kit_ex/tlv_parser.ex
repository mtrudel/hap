defmodule HomeKitEx.TLVParser do
  @behaviour Plug.Parsers

  def init(opts), do: opts

  def parse(conn, "application", "pairing+tlv8", _params, _opts) do
    {:ok, body, conn} = Plug.Conn.read_body(conn)
    {:ok, parse_tlv(body), conn}
  end

  def parse(conn, _type, _subtype, _params, _opts), do: {:next, conn}

  defp parse_tlv(str) do
    str
    |> Stream.unfold(fn str ->
      case str do
        <<tag::size(8), length::size(8), rest::binary>> ->
          <<value::binary-size(length), rest::binary>> = rest
          {{tag, value}, rest}

        <<>> ->
          nil
      end
    end)
    |> Map.new()
  end
end
