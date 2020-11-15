defmodule HAP.Characteristics.FirmwareRevision do
  def build_characteristic(value) do
    %HAP.Characteristic{type: "52", value: value, perms: ["pr"], format: "string"}
  end
end
