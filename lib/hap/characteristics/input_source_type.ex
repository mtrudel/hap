defmodule HAP.Characteristics.InputSourceType do
  @moduledoc """
  Definition of the `public.hap.characteristic.input-source-type` characteristic

  Valid values:
  0 - Other
  1 - Home Screen
  2 - Tuner
  3 - HDMI
  4 - Composite Video
  5 - S-Video
  6 - Component Video
  7 - DVI
  8 - AirPlay
  9 - USB
  10 - Application

  Specifies the type of input source.
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "DB"
  def perms, do: ["pr", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 10
  def step_value, do: 1
end
