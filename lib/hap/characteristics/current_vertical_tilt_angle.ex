defmodule HAP.Characteristics.CurrentVerticalTiltAngle do
  @moduledoc """
  Definition of the `public.hap.characteristic.vertical-tilt.current` characteristic
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "6E"
  def perms, do: ["pr", "ev"]
  def format, do: "int"
  def min_value, do: -90
  def max_value, do: 90
  def step_value, do: 1
  def units, do: "arcdegrees"
end
