defmodule HAP.Characteristics.VolumeSelector do
  @moduledoc """
  Definition of the `public.hap.characteristic.volume-selector` characteristic

  Valid values:
  0 - Increment
  1 - Decrement

  This is a write-only characteristic used to adjust volume in increments.
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "EA"
  def perms, do: ["pw"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 1
  def step_value, do: 1
end