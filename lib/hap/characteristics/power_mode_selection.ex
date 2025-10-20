defmodule HAP.Characteristics.PowerModeSelection do
  @moduledoc """
  Definition of the `public.hap.characteristic.power-mode-selection` characteristic

  Valid values:
  0 - Show (View TV Settings)
  1 - Hide (Hide TV Settings)

  This characteristic controls whether the television settings should be
  accessible in the Home app.
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "DF"
  def perms, do: ["pw"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 1
  def step_value, do: 1
end