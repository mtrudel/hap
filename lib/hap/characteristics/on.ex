defmodule HAP.Characteristics.On do
  def build_characteristic(mod, opts) do
    %HAP.Characteristic{type: "25", value_mod: mod, value_opts: opts, perms: ["pr", "pw", "ev"], format: "bool"}
  end
end
