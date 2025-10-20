defmodule HAP.Characteristics.CurrentVisibilityState do
  @moduledoc """
  Definition of the `public.hap.characteristic.current-visibility-state` characteristic

  Valid values:
  0 - Shown
  1 - Hidden

  Indicates whether this input source is currently shown or hidden in the UI.
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "135"
  def perms, do: ["pr", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 1
  def step_value, do: 1
end