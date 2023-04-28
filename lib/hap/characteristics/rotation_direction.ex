defmodule HAP.Characteristics.RotationDirection do
  @moduledoc """
  Definition of the `public.hap.characteristic.rotation.direction` characteristic

  Valid values

  0 Clockwise
  1 Counter-clockwise
  2-255 Reserved
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "28"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "int"
  def min_value, do: 0
  def max_value, do: 1
  def step_value, do: 1
end
