defmodule HAP.Characteristics.On do
  def build_characteristic(value) do
    %HAP.Characteristic{type: "25", value: value, perms: ["pr", "pw", "ev"], format: "bool"}
  end
end
