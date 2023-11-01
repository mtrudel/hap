defmodule HAP.Characteristics.LockCurrentState do
  @moduledoc """
  Definition of the `public.hap.characteristic.lock-mechanism.current-state` characteristic

  Valid values:

  0 Unsecured 
  1 Secured
  2 Jammed
  3 Unknowm

  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "1D"
  def perms, do: ["pr", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 3
  def step_value, do: 1
end
