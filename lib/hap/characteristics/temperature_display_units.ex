defmodule HAP.Characteristics.TemperatureDisplayUnits do
  @moduledoc """
  Factory for the `public.hap.characteristic.temperature.units` characteristic

  Valid values:

  0: Celsius
  1: Fahrenheit
  """

  def type, do: "36"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 1
  def step_unit, do: 1
end
