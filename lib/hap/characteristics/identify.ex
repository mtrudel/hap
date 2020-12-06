defmodule HAP.Characteristics.Identify do
  @moduledoc """
  Factory for the `public.hap.characteristic.identify` characteristic
  """

  @behaviour HAP.ValueStore

  def build_characteristic(name) do
    %HAP.Characteristic{type: "14", value_mod: __MODULE__, value_opts: [name: name], perms: ["pw"], format: "bool"}
  end

  @impl HAP.ValueStore
  def get_value(_) do
    raise "Cannot get value for identify"
  end

  @impl HAP.ValueStore
  def put_value(_value, name: name) do
    HAP.Display.identify(name)
  end
end
