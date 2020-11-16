defmodule HAP.Characteristics.Identify do
  @moduledoc """
  Factory for the `public.hap.characteristic.identify` characteristic
  """

  def build_characteristic(mod, opts) do
    %HAP.Characteristic{type: "14", value_mod: mod, value_opts: opts, perms: ["pw"], format: "bool"}
  end
end
