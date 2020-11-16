defmodule HAP.Characteristics.Manufacturer do
  @moduledoc """
  Factory for the `public.hap.characteristic.manufacturer` characteristic
  """

  def build_characteristic(value) do
    %HAP.Characteristic{type: "20", value: value, perms: ["pr"], format: "string"}
  end
end
