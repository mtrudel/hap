defmodule HAP.Characteristics.OccupancyDetected do
  @moduledoc """
  Definition of the `public.hap.characteristic.occupancy-detected` characteristic

  Valid values: 
  0: Occupancy is not detected
  1: Occupancy is detected
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "71"
  def perms, do: ["pr", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 1
  def step_value, do: 1
end
