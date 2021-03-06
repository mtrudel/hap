defmodule HAP.Characteristics.LockPhysicalControls do
  @moduledoc """
  Definition of the `public.hap.characteristic.lock-physical-controls` characteristic

  Valid values: 

  0: Control lock disabled
  1: Control lock enabled
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "A7"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 1
  def step_value, do: 1
end
