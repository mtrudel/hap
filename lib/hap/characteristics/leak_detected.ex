defmodule HAP.Characteristics.LeakDetected do
  @moduledoc """
  Definition of the `public.hap.characteristic.leak-detected` characteristic

  Valid values: 
  0: Leak is not detected
  1: Leak is detected
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "70"
  def perms, do: ["pr", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 1
  def step_value, do: 1
end
