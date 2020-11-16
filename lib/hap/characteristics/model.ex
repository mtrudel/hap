defmodule HAP.Characteristics.Model do
  @moduledoc """
  Factory for the `public.hap.characteristic.model` characteristic
  """

  def build_characteristic(value) do
    %HAP.Characteristic{type: "21", value: value, perms: ["pr"], format: "string"}
  end
end
