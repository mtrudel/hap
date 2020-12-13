defmodule HAP.Characteristics.CoolingThresholdTemperature do
  @moduledoc """
  Definition of the `public.hap.characteristic.temperature.cooling-threshold` characteristic
  """

  def type, do: "0D"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "float"
  def min_value, do: 10.0
  def max_value, do: 35.0
  def step_value, do: 0.1
  def units, do: "celsius"
end
