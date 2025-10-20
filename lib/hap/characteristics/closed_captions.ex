defmodule HAP.Characteristics.ClosedCaptions do
  @moduledoc """
  Definition of the `public.hap.characteristic.closed-captions` characteristic

  Valid values:
  0 - Closed Captions Disabled
  1 - Closed Captions Enabled

  Controls whether closed captions are displayed on the television.
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "DD"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 1
  def step_value, do: 1
end