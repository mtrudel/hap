defmodule HAP.Characteristics.SleepDiscoveryMode do
  @moduledoc """
  Definition of the `public.hap.characteristic.sleep-discovery-mode` characteristic

  Valid values:
  0 - Not Discoverable
  1 - Always Discoverable

  This characteristic determines whether the television accessory should be
  discoverable while in sleep mode.
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "E8"
  def perms, do: ["pr", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 1
  def step_value, do: 1
end
