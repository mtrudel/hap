defmodule HAP.Display do
  alias HAP.Configuration

  def display_startup_info() do
    if Configuration.paired?(), do: display_paired(), else: display_unpaired()
  end

  def display_unpaired do
    padding = 0
    version = 0
    reserved = 0
    hap_type = 2
    pairing_code_int = Configuration.pairing_code() |> String.replace("-", "") |> String.to_integer()

    payload =
      <<padding::2, version::3, reserved::4, Configuration.accessory_type()::8, hap_type::4, pairing_code_int::27>>
      |> :binary.decode_unsigned()
      |> Base36.encode()

    url = "X-HM://00#{payload}#{Configuration.setup_id()}"

    IO.puts("\e[1m")
    IO.puts("#{Configuration.name()} available for pairing. Connect using the following QR Code")

    url
    |> EQRCode.encode()
    |> EQRCode.render()

    IO.puts("""
    \e[1m
                       Manual Setup Code
                        ┌────────────┐
                        │ #{Configuration.pairing_code()} │
                        └────────────┘
    \e[0m
    """)
  end

  def display_paired do
    IO.puts("#{Configuration.name()} paired and running")
  end

  def display_new_pairing_info(ios_identifier) do
    IO.puts("Paired with controller #{ios_identifier}")
  end
end
