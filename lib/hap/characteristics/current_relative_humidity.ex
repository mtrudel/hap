defmodule HAP.Characteristics.CurrentRelativeHumidity do
  @moduledoc """
  Definition of the `public.hap.characteristic.relative-humidity.current` characteristic
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "10"
  def perms, do: ["pr", "ev"]
  def format, do: "float"
  def min_value, do: 0
  def max_value, do: 100
  def step_value, do: 1
  def unit, do: "percentage"
end
