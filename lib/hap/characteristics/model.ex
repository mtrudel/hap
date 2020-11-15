defmodule HAP.Characteristics.Model do
  def build_characteristic(value) do
    %HAP.Characteristic{type: "21", value: value, perms: ["pr"], format: "string"}
  end
end
