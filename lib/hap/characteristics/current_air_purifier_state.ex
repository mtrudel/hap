defmodule HAP.Characteristics.CurrentAirPurifierState do
  @moduledoc """
  Definition of the `public.hap.characteristic.air-purifier.state.current` characteristic

  Valid values:

  0 Inactive
  1 Idle
  2 Purifying Air
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "A9"
  def perms, do: ["pr", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 2
  def step_value, do: 1
end
