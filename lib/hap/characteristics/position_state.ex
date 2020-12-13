defmodule HAP.Characteristics.PositionState do
  @moduledoc """
  Definition of the `public.hap.characteristic.position.state` characteristic

  Valid values:
  0: Going to the minimum value specified in metadata
  1: Going to the maximum value specified in metadata
  2: Stopped

  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "72"
  def perms, do: ["pr", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 2
  def step_value, do: 1
end
