defmodule HAP.Characteristics.CurrentHorizontalTiltAngle do
  @moduledoc """
  Definition of the `public.hap.characteristic.horizontal-tilt.current` characteristic
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "6C"
  def perms, do: ["pr", "ev"]
  def format, do: "int"
  def min_value, do: -90
  def max_value, do: 90
  def step_value, do: 1
  def units, do: "arcdegrees"
end
