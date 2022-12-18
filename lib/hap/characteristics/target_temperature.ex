defmodule HAP.Characteristics.TargetTemperature do
  @moduledoc """
  Definition of the `public.hap.characteristic.temperature.target` characteristic
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "35"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "float"
  def min_value, do: 10
  def max_value, do: 38
  def step_value, do: 0.1
end
