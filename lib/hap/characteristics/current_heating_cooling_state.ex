defmodule HAP.Characteristics.CurrentHeatingCoolingState do
  @moduledoc """
  Definition of the `public.hap.characteristic.heating-cooling.state.current` characteristic

  Valid values:

  0 Off
  1 Heating
  2 Cooling
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "F"
  def perms, do: ["pr", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 2
  def step_value, do: 1
end
