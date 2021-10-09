defmodule HAP.Characteristics.Volume do
  @moduledoc """
  Definition of the `public.hap.characteristic.volume` characteristic
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "119"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 100
  def step_value, do: 1
  def unit, do: "percentage"
end
