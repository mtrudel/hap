defmodule HAP.Characteristics.CurrentSlatState do
  @moduledoc """
  Definition of the `public.hap.characteristic.slat.state.current` characteristic

  Valid values:

  0 Fixed
  1 Jammed
  2 Swinging

  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "AA"
  def perms, do: ["pr", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 2
  def step_value, do: 1
end
