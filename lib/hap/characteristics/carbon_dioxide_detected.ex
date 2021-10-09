defmodule HAP.Characteristics.CarbonDioxideDetected do
  @moduledoc """
  Definition of the `public.hap.characteristic.carbon-dioxide.detected` characteristic

  Valid values:
  0: Carbon Dioxide levels are normal
  1: Carbon Dioxide levels are abnormal
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "92"
  def perms, do: ["pr", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 1
  def step_value, do: 1
end
