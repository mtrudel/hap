defmodule HAP.Characteristics.InputDeviceType do
  @moduledoc """
  Definition of the `public.hap.characteristic.input-device-type` characteristic

  Valid values:
  0 - Other
  1 - TV
  2 - Recording
  3 - Tuner
  4 - Playback
  5 - Audio System

  Specifies the type of device connected to this input source.
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "DC"
  def perms, do: ["pr", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 5
  def step_value, do: 1
end