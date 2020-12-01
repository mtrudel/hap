defmodule HAP.TLVEncoder do
  @moduledoc false
  # Provides functions to encode a map or keyword list into a TLV binary as described
  # in Apple's [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/).

  @doc """
  Converts the provided map or keyword list into a TLV binary
  """
  def to_binary(tlv) do
    tlv
    |> Enum.flat_map(&to_single_tlv/1)
    |> Enum.join()
  end

  defp to_single_tlv({tag, value}) do
    case value do
      <<value::binary-255, rest::binary>> ->
        [<<tag::8, byte_size(value)::8, value::binary>> | to_single_tlv({tag, rest})]

      <<>> ->
        []

      <<value::binary>> ->
        [<<tag::8, byte_size(value)::8, value::binary>>]
    end
  end
end
