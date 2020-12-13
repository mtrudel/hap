defmodule HAP.Characteristics.ColorTemperature do
  @moduledoc """
  Definition of the `public.hap.characteristic.color-temperature` characteristic

  This characteristic describes color temperature which is represented in reciprocal 
  megaKelvin (MK-1) or mirek scale. (M = 1,000,000 / K where M is the desired mirek 
  value and K is temperature in Kelvin)
  """

  def type, do: "CE"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "uint32"
  def min_value, do: 50
  def max_value, do: 400
  def step_unit, do: 1
end
