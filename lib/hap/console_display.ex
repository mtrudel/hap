defmodule HAP.ConsoleDisplay do
  @moduledoc false
  # A simple console based implementation of the HAP.Display behaviour

  @behaviour HAP.Display

  @impl HAP.Display
  def display_pairing_code(name, pairing_code, pairing_url) do
    IO.puts("\e[1m")
    IO.puts("#{name} available for pairing. Connect using the following QR Code")

    pairing_url
    |> EQRCode.encode()
    |> EQRCode.render()

    IO.puts("""
    \e[1m
                       Manual Setup Code
                        ┌────────────┐
                        │ #{pairing_code} │
                        └────────────┘
    \e[0m
    """)
  end

  @impl HAP.Display
  def clear_pairing_code, do: :ok

  @impl HAP.Display
  def identify(name), do: IO.puts("Identifying #{name}")
end
