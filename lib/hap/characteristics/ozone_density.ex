defmodule HAP.Characteristics.OzoneDensity do
  @moduledoc """
  Definition of the `public.hap.characteristic.density.ozone` characteristic
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "C3"
  def perms, do: ["pr", "ev"]
  def format, do: "float"
  def min_value, do: 0
  def max_value, do: 1000
end
