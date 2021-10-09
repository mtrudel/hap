defmodule HAP.Characteristics.CarbonMonoxideLevel do
  @moduledoc """
  Definition of the `public.hap.characteristic.carbon-monoxide.level` characteristic
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "90"
  def perms, do: ["pr", "ev"]
  def format, do: "float"
  def min_value, do: 0
  def max_value, do: 100
end
