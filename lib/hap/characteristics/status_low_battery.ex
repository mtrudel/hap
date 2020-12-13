defmodule HAP.Characteristics.StatusLowBattery do
  @moduledoc """
  Definition of the `public.hap.characteristic.status-lo-batt` characteristic

  A status of 1 indicates that the battery level of the accessory is low. 
  Value should return to 0 when the battery charges to a level thats above the 
  low threshold.
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "79"
  def perms, do: ["pr", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 1
  def step_value, do: 1
end
