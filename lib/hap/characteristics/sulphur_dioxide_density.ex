defmodule HAP.Characteristics.SulphurDioxideDensity do
  @moduledoc """
  Definition of the `public.hap.characteristic.density.so2` characteristic
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "C5"
  def perms, do: ["pr", "ev"]
  def format, do: "float"
  def min_value, do: 0
  def max_value, do: 1000
end
