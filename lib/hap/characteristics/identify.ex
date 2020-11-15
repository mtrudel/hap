defmodule HAP.Characteristics.Identify do
  def build_characteristic(_value \\ nil) do
    %HAP.Characteristic{type: "14", perms: ["pw"], format: "bool"}
  end
end
