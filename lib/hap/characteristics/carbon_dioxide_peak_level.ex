defmodule HAP.Characteristics.CarbonDioxidePeakLevel do
  @moduledoc """
  Definition of the `public.hap.characteristic.carbon-dioxide.peak-level` characteristic
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "94"
  def perms, do: ["pr", "ev"]
  def format, do: "float"
  def min_value, do: 0
  def max_value, do: 100_000
end
