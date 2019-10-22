defmodule HomeKitEx.TLVEncoderTest do
  use ExUnit.Case

  test "encodes properly" do
    expected =
      <<1, 255>> <>
        :binary.copy(<<0xAA>>, 255) <>
        <<1, 255>> <> :binary.copy(<<0xAB>>, 255) <> <<1, 10>> <> :binary.copy(<<0xBA>>, 10) <> <<2, 1, 3>>

    data = :binary.copy(<<0xAA>>, 255) <> :binary.copy(<<0xAB>>, 255) <> :binary.copy(<<0xBA>>, 10)

    assert HomeKitEx.TLVEncoder.to_binary(%{1 => data, 2 => <<3>>}) == expected
  end
end
