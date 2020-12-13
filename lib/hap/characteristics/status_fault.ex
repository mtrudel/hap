defmodule HAP.Characteristics.StatusFault do
  @moduledoc """
  Factory for the `public.hap.characteristic.status-fault` characteristic

  A non-zero value indicates that the accessory has experienced a fault that 
  may be interfering with its intended functionality. A value of 0 indicates 
  that there is no fault.
  """

  def type, do: "77"
  def perms, do: ["pr", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 1
  def step_unit, do: 1
end
