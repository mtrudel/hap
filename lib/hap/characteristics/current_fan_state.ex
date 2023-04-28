defmodule HAP.Characteristics.CurrentFanState do
  @moduledoc """
  Definition of the `public.hap.characteristic.fan.state.current` characteristic

  Valid values:

  0 Inactive
  1 Idle
  2 Blowing Air
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "AF"
  def perms, do: ["pr", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 2
  def step_value, do: 1
end
