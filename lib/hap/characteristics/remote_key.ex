defmodule HAP.Characteristics.RemoteKey do
  @moduledoc """
  Definition of the `public.hap.characteristic.remote-key` characteristic

  Valid values for Apple TV remote control:
  0 - Rewind
  1 - Fast Forward
  2 - Next Track
  3 - Previous Track
  4 - Arrow Up
  5 - Arrow Down
  6 - Arrow Left
  7 - Arrow Right
  8 - Select
  9 - Back
  10 - Exit
  11 - Play/Pause
  15 - Information

  This is a write-only characteristic that receives remote control
  button presses from HomeKit.
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "E1"
  def perms, do: ["pw"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 16
  def step_value, do: 1
end
