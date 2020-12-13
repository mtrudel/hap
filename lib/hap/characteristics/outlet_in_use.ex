defmodule HAP.Characteristics.OutletInUse do
  @moduledoc """
  Definition of the `public.hap.characteristic.outlet-in-use` characteristic
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "26"
  def perms, do: ["pr", "ev"]
  def format, do: "bool"
end
