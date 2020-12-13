defmodule HAP.Characteristics.HeatingThresholdTemperature do
  @moduledoc """
  Factory for the `public.hap.characteristic.temperature.heating-threshold` characteristic
  """

  def type, do: "12"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "float"
  def min_value, do: 0.0
  def max_value, do: 25.0
  def step_unit, do: 0.1
  def units, do: "celsius"
end
