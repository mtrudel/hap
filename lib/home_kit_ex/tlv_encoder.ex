defmodule HomeKitEx.TLVEncoder do
  def to_binary(tlv) do
    tlv
    |> Enum.flat_map(&to_single_tlv/1)
    |> Enum.join()
  end

  defp to_single_tlv({tag, value}) do
    case value do
      <<value::binary-size(255), rest::binary>> ->
        [<<tag::size(8), byte_size(value)::size(8), value::binary>> | to_single_tlv({tag, rest})]

      <<>> ->
        []

      <<value::binary>> ->
        [<<tag::size(8), byte_size(value)::size(8), value::binary>>]
    end
  end
end
