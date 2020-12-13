defmodule HAP.Characteristics.CurrentPosition do
  @moduledoc """
  Definition of the `public.hap.characteristic.position.current` characteristic
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "6D"
  def perms, do: ["pr", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 100
  def step_value, do: 1
  def unit, do: "percentage"
end
