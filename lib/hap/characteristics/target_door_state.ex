defmodule HAP.Characteristics.TargetDoorState do
  @moduledoc """
  Definition of the `public.hap.characteristic.door-state.target` characteristic

  Valid values:

  0 Open    - The door is fully open
  1 Closed  - The door is fully closed

  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "32"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 1
  def step_value, do: 1
end
