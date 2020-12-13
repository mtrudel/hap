defmodule HAP.Characteristics.TargetVerticalTiltAngle do
  @moduledoc """
  Definition of the `public.hap.characteristic.vertical-tilt.target` characteristic
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "7D"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "int"
  def min_value, do: -90
  def max_value, do: 90
  def step_value, do: 1
  def units, do: "arcdegrees"
end
