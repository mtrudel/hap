defmodule HAP.Display do
  def display_startup_info(config, %HAP.PairingStates.Unpaired{pairing_code: pairing_code}) do
    padding = 0
    version = 0
    reserved = 0
    hap_type = 2
    pairing_code_int = pairing_code |> String.replace("-", "") |> String.to_integer()

    payload =
      <<padding::2, version::3, reserved::4, config.accessory_type::8, hap_type::4, pairing_code_int::27>>
      |> :binary.decode_unsigned()
      |> Base36.encode()

    url = "X-HM://00#{payload}#{config.setup_id}"

    IO.puts("\e[1m")
    IO.puts("#{config.name} available for pairing. Connect using the following QR Code")

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

  def display_startup_info(config, %HAP.PairingStates.Paired{}) do
    IO.puts("#{config.name} paired and running")
  end

  def display_startup_info(config, _pairing_state) do
    IO.puts("#{config.name} is in the process of pairing")
  end
end
