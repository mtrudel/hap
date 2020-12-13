defmodule HAP.Characteristics.Saturation do
  @moduledoc """
  Definition of the `public.hap.characteristic.saturation` characteristic
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "2F"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "float"
  def min_value, do: 0.0
  def max_value, do: 100.0
  def step_value, do: 1.0
  def unit, do: "percentage"
end
