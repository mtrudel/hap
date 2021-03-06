defmodule HAP.Characteristics.TemperatureDisplayUnits do
  @moduledoc """
  Definition of the `public.hap.characteristic.temperature.units` characteristic

  Valid values:

  0: Celsius
  1: Fahrenheit
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "36"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 1
  def step_value, do: 1
end
