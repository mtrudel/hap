defmodule HAP.Characteristics.WaterLevel do
  @moduledoc """
  Definition of the `public.hap.characteristic.water-level` characteristic
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "B5"
  def perms, do: ["pr", "ev"]
  def format, do: "float"
  def min_value, do: 0.0
  def max_value, do: 100.0
  def step_value, do: 1.0
  def unit, do: "percentage"
end
