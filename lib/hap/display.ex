defmodule HAP.Display do
  @hap_type_ip 2

  def display_pairing_code(accessory_type, pairing_code, setup_code) do
    padding = 0
    version = 0
    reserved = 0
    hap_type = @hap_type_ip
    pairing_code_int = pairing_code |> String.replace("-", "") |> String.to_integer()

    payload =
      <<padding::size(2), version::size(3), reserved::size(4), accessory_type::size(8), hap_type::size(4),
        pairing_code_int::size(27)>>
      |> :binary.decode_unsigned()
      |> Base36.encode()

    url = "X-HM://00#{payload}#{setup_code}"

    url
    |> EQRCode.encode()
    |> EQRCode.render()

    IO.puts("\e[1m")
    IO.puts("                     Manual Setup Code")
    IO.puts("                      ┌────────────┐")
    IO.puts("                      │ #{pairing_code} │")
    IO.puts("                      └────────────┘")
    IO.puts("\e[0m")
    IO.puts("")
    IO.puts("")
  end
end
