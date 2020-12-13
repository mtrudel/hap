defmodule HAP.Characteristics.TargetHorizontalTiltAngle do
  @moduledoc """
  Definition of the `public.hap.characteristic.horizontal-tilt.target` characteristic
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "7B"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "int"
  def min_value, do: -90
  def max_value, do: 90
  def step_value, do: 1
  def units, do: "arcdegrees"
end
