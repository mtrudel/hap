defmodule HAP.TLVParserTest do
  use ExUnit.Case

  test "parses multi-segment entries properly" do
    data =
      <<1, 255>> <>
        :binary.copy(<<0xAA>>, 255) <>
        <<1, 255>> <> :binary.copy(<<0xAB>>, 255) <> <<1, 10>> <> :binary.copy(<<0xBA>>, 10) <> <<2, 1, 3>>

    expected = :binary.copy(<<0xAA>>, 255) <> :binary.copy(<<0xAB>>, 255) <> :binary.copy(<<0xBA>>, 10)

    assert HAP.TLVParser.parse_tlv(data) == %{1 => expected, 2 => <<3>>}
  end
end
