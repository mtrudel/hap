defmodule HAP.Characteristics.TargetFanState do
  @moduledoc """
  Definition of the `public.hap.characteristic.fan.state.target` characteristic

  Valid values:

  0 Manual
  1 Auto
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "BF"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 1
  def step_value, do: 1
end
