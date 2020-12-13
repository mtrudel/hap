defmodule HAP.Characteristics.CurrentTemperature do
  @moduledoc """
  Definition of the `public.hap.characteristic.temperature.current` characteristic
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "11"
  def perms, do: ["pr", "ev"]
  def format, do: "float"
  def min_value, do: 0.0
  def max_value, do: 100.0
  def step_value, do: 0.1
  def unit, do: "celsius"
end
