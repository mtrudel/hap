defmodule HAP.Characteristics.Manufacturer do
  def build_characteristic(value) do
    %HAP.Characteristic{type: "20", value: value, perms: ["pr"], format: "string"}
  end
end
