defmodule HAP.Characteristics.SerialNumber do
  def build_characteristic(value) do
    %HAP.Characteristic{type: "30", value: value, perms: ["pr"], format: "string"}
  end
end
