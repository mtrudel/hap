defmodule HAP.Characteristics.SlatType do
  @moduledoc """
  Definition of the `public.hap.characteristic.type.slat` characteristic

  Valid values:

  0 Horizontal
  1 Vertical

  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "C0"
  def perms, do: ["pr"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 1
  def step_value, do: 1
end
