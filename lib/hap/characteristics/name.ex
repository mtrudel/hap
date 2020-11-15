defmodule HAP.Characteristics.Name do
  def build_characteristic(value) do
    %HAP.Characteristic{type: "23", value: value, perms: ["pr"], format: "string"}
  end
end
