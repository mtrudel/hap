defmodule HAP.TLVParserTest do
  use ExUnit.Case
  use Plug.Test

  test "parses multi-segment entries properly in a conn" do
    data =
      <<1, 255>> <>
        :binary.copy(<<0xAA>>, 255) <>
        <<1, 255>> <> :binary.copy(<<0xAB>>, 255) <> <<1, 10>> <> :binary.copy(<<0xBA>>, 10) <> <<2, 1, 3>>

    expected = %{
      1 => :binary.copy(<<0xAA>>, 255) <> :binary.copy(<<0xAB>>, 255) <> :binary.copy(<<0xBA>>, 10),
      2 => <<3>>
    }

    {:ok, result, _conn} =
      conn("METHOD", "path", data)
      |> HAP.TLVParser.parse("application", "pairing+tlv8", {}, {})

    assert result == expected
  end

  test "parses multi-segment entries properly as a string" do
    data =
      <<1, 255>> <>
        :binary.copy(<<0xAA>>, 255) <>
        <<1, 255>> <> :binary.copy(<<0xAB>>, 255) <> <<1, 10>> <> :binary.copy(<<0xBA>>, 10) <> <<2, 1, 3>>

    expected = %{
      1 => :binary.copy(<<0xAA>>, 255) <> :binary.copy(<<0xAB>>, 255) <> :binary.copy(<<0xBA>>, 10),
      2 => <<3>>
    }

    assert HAP.TLVParser.parse_tlv(data) == expected
  end
end
