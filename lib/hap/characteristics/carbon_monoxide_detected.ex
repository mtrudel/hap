defmodule HAP.Characteristics.CarbonMonoxideDetected do
  @moduledoc """
  Definition of the `public.hap.characteristic.carbon-monoxide.detected` characteristic

  Valid values:
  0: Carbon Monoxide levels are normal
  1: Carbon Monoxide levels are abnormal
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "69"
  def perms, do: ["pr", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 1
  def step_value, do: 1
end
