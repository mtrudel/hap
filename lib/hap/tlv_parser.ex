defmodule HAP.TLVParser do
  @moduledoc """
  A `Plug.Parsers` compliant parser for TLV payloads as described in the Appendix of 
  Apple's [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/). 
  """

  @behaviour Plug.Parsers

  @impl Plug.Parsers
  def init(opts), do: opts

  @impl Plug.Parsers
  def parse(conn, "application", "pairing+tlv8", _params, _opts) do
    {:ok, body, conn} = Plug.Conn.read_body(conn)
    {:ok, parse_tlv(body), conn}
  end

  def parse(conn, _type, _subtype, _params, _opts), do: {:next, conn}

  defp parse_tlv(str) do
    str
    |> Stream.unfold(&next_tag/1)
    |> Map.new()
  end

  defp next_tag(str) do
    case str do
      <<tag::8, 255, value::binary-255, next_tag::8, rest::binary>> when tag == next_tag ->
        {{_, next_value}, next_rest} = next_tag(<<next_tag>> <> rest)
        {{tag, value <> next_value}, next_rest}

      <<tag::8, length::8, rest::binary>> ->
        <<value::binary-size(length), rest::binary>> = rest
        {{tag, value}, rest}

      <<>> ->
        nil
    end
  end
end
