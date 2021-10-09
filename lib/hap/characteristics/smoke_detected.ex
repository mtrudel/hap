defmodule HAP.Characteristics.SmokeDetected do
  @moduledoc """
  Definition of the `public.hap.characteristic.smoke-detected` characteristic

  Valid values:
  0: Smoke is not detected
  1: Smoke is detected
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "76"
  def perms, do: ["pr", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 1
  def step_value, do: 1
end
