defmodule HAP.Characteristics.Saturation do
  @moduledoc """
  Factory for the `public.hap.characteristic.saturation` characteristic
  """

  def type, do: "2F"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "float"
  def min_value, do: 0.0
  def max_value, do: 100.0
  def step_unit, do: 1.0
  def unit, do: "percentage"
end
