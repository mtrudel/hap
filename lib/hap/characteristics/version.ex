defmodule HAP.Characteristics.Version do
  @moduledoc """
  Factory for the `public.hap.characteristic.version` characteristic
  """

  def build_characteristic(value) do
    %HAP.Characteristic{type: "37", value: value, perms: ["pr"], format: "string"}
  end
end
