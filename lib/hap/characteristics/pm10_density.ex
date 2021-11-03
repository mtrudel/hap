defmodule HAP.Characteristics.PM10Density do
  @moduledoc """
  Definition of the `public.hap.characteristic.density.pm10` characteristic
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "C7"
  def perms, do: ["pr", "ev"]
  def format, do: "float"
  def min_value, do: 0
  def max_value, do: 1000
end
