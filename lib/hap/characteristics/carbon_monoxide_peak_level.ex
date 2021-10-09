defmodule HAP.Characteristics.CarbonMonoxidePeakLevel do
  @moduledoc """
  Definition of the `public.hap.characteristic.carbon-monoxide.peak-level` characteristic
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "91"
  def perms, do: ["pr", "ev"]
  def format, do: "float"
  def min_value, do: 0
  def max_value, do: 100
end
