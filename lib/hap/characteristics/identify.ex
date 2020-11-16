defmodule HAP.Characteristics.Identify do
  def build_characteristic(mod, opts) do
    %HAP.Characteristic{type: "14", value_mod: mod, value_opts: opts, perms: ["pw"], format: "bool"}
  end
end
