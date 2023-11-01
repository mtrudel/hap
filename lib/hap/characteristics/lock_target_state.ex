defmodule HAP.Characteristics.LockTargetState do
  @moduledoc """
  Definition of the `public.hap.characteristic.lock-mechanism.target-state` characteristic

  Valid values:

  0 Unsecured 
  1 Secured

  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "1E"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 1
  def step_value, do: 1
end
