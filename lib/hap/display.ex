defmodule HAP.Display do
  @moduledoc """
  Centralized functions for non-logging related display functionality
  """

  @callback display_pairing_code(String.t(), String.t(), String.t()) :: any()
  @callback clear_pairing_code() :: any()
  @callback identify(String.t()) :: any()

  alias HAP.AccessoryServerManager

  def update_pairing_info_display do
    if AccessoryServerManager.paired?() do
      AccessoryServerManager.display_module().clear_pairing_code()
    else
      name = AccessoryServerManager.name()
      pairing_code = AccessoryServerManager.pairing_code()
      pairing_url = build_pairing_url()
      AccessoryServerManager.display_module().display_pairing_code(name, pairing_code, pairing_url)
    end
  end

  def identify(name) do
    AccessoryServerManager.display_module().identify(name)
  end

  defp build_pairing_url do
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

    "X-HM://00#{payload}#{AccessoryServerManager.setup_id()}"
  end
end
