defmodule HAP.Characteristics.CurrentDoorState do
  @moduledoc """
  Definition of the `public.hap.characteristic.door-state.current` characteristic

  Valid values:

  0 Open    - The door is fully open
  1 Closed  - The door is fully closed
  2 Opening - The door is actively opening
  3 Closing - The door is actively closing
  4 Stopped - The door is not moving, and it is not fully open nor fully closed

  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "E"
  def perms, do: ["pr", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 4
  def step_value, do: 1
end
