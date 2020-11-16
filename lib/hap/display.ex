defmodule HAP.Display do
  alias HAP.AccessoryServerManager

  def update_pairing_info_display do
    if !AccessoryServerManager.paired?(), do: display_pairing_code()
  end

  def identify(name) do
    IO.puts("Identifying #{name}")
  end

  defp display_pairing_code do
    padding = 0
    version = 0
    reserved = 0
    hap_type = 2
    pairing_code_int = AccessoryServerManager.pairing_code() |> String.replace("-", "") |> String.to_integer()

    payload =
      <<padding::2, version::3, reserved::4, AccessoryServerManager.accessory_type()::8, hap_type::4,
        pairing_code_int::27>>
      |> :binary.decode_unsigned()
      |> Base36.encode()

    url = "X-HM://00#{payload}#{AccessoryServerManager.setup_id()}"

    IO.puts("\e[1m")
    IO.puts("#{AccessoryServerManager.name()} available for pairing. Connect using the following QR Code")

    url
    |> EQRCode.encode()
    |> EQRCode.render()

    IO.puts("""
    \e[1m
                       Manual Setup Code
                        ┌────────────┐
                        │ #{AccessoryServerManager.pairing_code()} │
                        └────────────┘
    \e[0m
    """)
  end
end
