defmodule HAP.Characteristics.TargetRelativeHumidity do
  @moduledoc """
  Definition of the `public.hap.characteristic.relative.humidity.target` characteristic
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "34"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "float"
  def min_value, do: 0
  def max_value, do: 100
  def step_value, do: 1
end
