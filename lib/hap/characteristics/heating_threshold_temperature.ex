defmodule HAP.Characteristics.HeatingThresholdTemperature do
  @moduledoc """
  Definition of the `public.hap.characteristic.temperature.heating-threshold` characteristic
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "12"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "float"
  def min_value, do: 0.0
  def max_value, do: 25.0
  def step_value, do: 0.1
  def units, do: "celsius"
end
