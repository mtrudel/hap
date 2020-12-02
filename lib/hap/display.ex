defmodule HAP.Display do
  @moduledoc """
  A behaviour which encapsulates all user-facing display concerns for an accessory.  Applications which use HAP may
  provide their own implementation of this behaviour as a field in a `HAP.AccessoryServer`. If no such
  implementation is provided HAP uses a default console based implementation
  """

  @doc """
  Display a notification to the user containing information on how to pair with
  this accessory server. The value of `pairing_url` can be encoded in a QR code
  to enable pairing directly from an iOS device.
  """
  @callback display_pairing_code(
              name :: HAP.AccessoryServer.name(),
              pairing_code :: HAP.AccessoryServer.pairing_code(),
              pairing_url :: HAP.AccessoryServer.pairing_url()
            ) ::
              any()

  @doc """
  Stop displaying any currently displayed pairing information to the user. This is
  most commonly because a pairing has been established with a controller
  """
  @callback clear_pairing_code() :: any()

  @doc """
  Display a notification to the user that identifies the named device or accessory.
  This comes from a user request within the Home app to identify the given device 
  or accessory.
  """
  @callback identify(String.t()) :: any()

  alias HAP.AccessoryServerManager

  @doc false
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

  @doc false
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
