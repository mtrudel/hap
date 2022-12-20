defmodule HAP.KinoDisplay do
  @moduledoc false
  # A Kino based implementation of the HAP.Display behaviour for livebook usage

  @behaviour HAP.Display

  @impl HAP.Display

  if Code.ensure_loaded?(Kino) do
    def display_pairing_code(name, pairing_code, pairing_url) do
      intro = Kino.Markdown.new("### #{name} available for pairing. Connect using the following QR Code")

      png_qr_code =
        pairing_url
        |> EQRCode.encode()
        |> EQRCode.png()
        |> Kino.Image.new("image/png")

      manual_pairing_info =
        Kino.Markdown.new("""
        | Manual Setup Code |
        | -- |
        | #{pairing_code} |
        """)

      Kino.render(intro)
      Kino.render(png_qr_code)
      Kino.render(manual_pairing_info)
    end
  else
    def display_pairing_code(_name, _pairing_code, _pairing_url) do
      IO.puts("Kino not available - use other HAP display module, or ensure Kino is installed")
    end
  end

  @impl HAP.Display
  def clear_pairing_code, do: :ok

  @impl HAP.Display
  def identify(name), do: IO.puts("Identifying #{name}")
end
