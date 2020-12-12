defmodule HAP.Characteristics.Hue do
  @moduledoc """
  Factory for the `public.hap.characteristic.hue` characteristic
  """

  def type, do: "13"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "float"
  def min_value, do: 0.0
  def max_value, do: 360.0
  def step_unit, do: 1.0
  def unit, do: "arcdegrees"
end
