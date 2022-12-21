defmodule HAP.Characteristics.InputEvent do
  @moduledoc """
  Definition of the `public.hap.characteristic.input-event` characteristic

  Valid values:
  0 ”Single Press”
  1 ”Double Press”
  2 ”Long Press”

  NOTE specification requirement:
  For IP accessories, the accessory must set the value of Paired Read to null(i.e. ”value” : null) in the attribute database. A read of this characteristic must always return a null value for IP accessories.

  The value must only be reported in the events (”ev”) property.
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "73"
  def perms, do: ["pr", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 2
  def step_value, do: 1
  def event_only, do: true
end
