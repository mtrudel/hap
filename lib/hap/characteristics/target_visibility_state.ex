defmodule HAP.Characteristics.TargetVisibilityState do
  @moduledoc """
  Definition of the `public.hap.characteristic.target-visibility-state` characteristic

  Valid values:
  0 - Shown
  1 - Hidden

  Used to control whether this input source should be shown or hidden in the UI.
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "134"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 1
  def step_value, do: 1
end
