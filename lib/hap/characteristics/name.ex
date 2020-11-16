defmodule HAP.Characteristics.Name do
  @moduledoc """
  Factory for the `public.hap.characteristic.name` characteristic
  """

  def build_characteristic(value) do
    %HAP.Characteristic{type: "23", value: value, perms: ["pr"], format: "string"}
  end
end
