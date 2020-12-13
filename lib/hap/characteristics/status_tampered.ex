defmodule HAP.Characteristics.StatusTampered do
  @moduledoc """
  Definition of the `public.hap.characteristic.status-tampered` characteristic

  This characteristic describes an accessory which has been tampered with. 
  A status of 1 indicates that the accessory has been tampered with. Value 
  should return to 0 when the accessory has been reset to a non-tampered state.
  """

  def type, do: "7A"
  def perms, do: ["pr", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 1
  def step_value, do: 1
end
