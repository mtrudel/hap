defmodule HAP.KinoDisplay do
  @moduledoc false
  # A Kino based implementation of the HAP.Display behaviour for livebook usage

  @behaviour HAP.Display

  @impl HAP.Display
  def display_pairing_code(name, pairing_code, pairing_url) do
    if Code.ensure_loaded?(Kino) do
      png_qr_code =
        pairing_url
        |> EQRCode.encode()
        |> EQRCode.png()
        |> Base.encode64()

      pairing_info =
        Kino.Markdown.new("""
        ### #{name} available for pairing. Connect using the following QR Code

        ![qr code](data:image/png;base64,#{png_qr_code})

        | Manual Setup Code |
        | -- |
        | #{pairing_code} |
        """)

      Kino.render(pairing_info)
    else
      IO.puts("Kino not available - use other HAP display module, or ensure Kino is installed")
    end
  end

  @impl HAP.Display
  def clear_pairing_code, do: :ok

  @impl HAP.Display
  def identify(name), do: IO.puts("Identifying #{name}")
end
