defmodule HAP.Characteristics.TargetTiltAngle do
  @moduledoc """
  Definition of the `public.hap.characteristic.tilt.target` characteristic
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "C2"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "int"
  def min_value, do: -90
  def max_value, do: 90
  def step_value, do: 1
  def units, do: "arcdegrees"
end
