defmodule HAP.Characteristics.IsConfigured do
  @moduledoc """
  Definition of the `public.hap.characteristic.is-configured` characteristic

  Valid values:
  0 - Not Configured
  1 - Configured

  Indicates whether this input source has been configured.
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "D6"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 1
  def step_value, do: 1
end
