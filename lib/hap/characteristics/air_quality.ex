defmodule HAP.Characteristics.AirQuality do
  @moduledoc """
  Definition of the `public.hap.characteristic.air-quality` characteristic

  Valid values:

  0 Unknown
  1 Excellent
  2 Good
  3 Fair
  4 Inferior
  5 Poor
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "95"
  def perms, do: ["pr", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 5
  def step_value, do: 1
end
