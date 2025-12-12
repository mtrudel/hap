defmodule HAP.Characteristics.VolumeControlType do
  @moduledoc """
  Definition of the `public.hap.characteristic.volume-control-type` characteristic

  Valid values:
  0 - None
  1 - Relative
  2 - Relative with Current
  3 - Absolute

  Specifies the type of volume control supported by the television speaker.
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "E9"
  def perms, do: ["pr", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 3
  def step_value, do: 1
end
