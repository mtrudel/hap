defmodule HAP.Characteristics.CurrentTemperature do
  @moduledoc """
  Factory for the `public.hap.characteristic.temperature.current` characteristic
  """

  def type, do: "11"
  def perms, do: ["pr", "ev"]
  def format, do: "float"
  def min_value, do: 0.0
  def max_value, do: 100.0
  def step_unit, do: 0.1
  def unit, do: "celsius"
end