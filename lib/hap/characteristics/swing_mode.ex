defmodule HAP.Characteristics.SwingMode do
  @moduledoc """
  Definition of the `public.hap.characteristic.swing-mode` characteristic

  Valid values:

  0: Swing disabled
  1: Swing enabled
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "B6"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 1
  def step_value, do: 1
end
