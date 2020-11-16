defmodule HAP.Characteristics.FirmwareRevision do
  @moduledoc """
  Factory for the `public.hap.characteristic.firmware.revision` characteristic
  """

  def build_characteristic(value) do
    %HAP.Characteristic{type: "52", value: value, perms: ["pr"], format: "string"}
  end
end
