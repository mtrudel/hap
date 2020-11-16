defmodule HAP.Characteristics.SerialNumber do
  @moduledoc """
  Factory for the `public.hap.characteristic.serial-number` characteristic
  """

  def build_characteristic(value) do
    %HAP.Characteristic{type: "30", value: value, perms: ["pr"], format: "string"}
  end
end
