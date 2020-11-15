defmodule HAP.Characteristics.Version do
  def build_characteristic(value) do
    %HAP.Characteristic{type: "37", value: value, perms: ["pr"], format: "string"}
  end
end
