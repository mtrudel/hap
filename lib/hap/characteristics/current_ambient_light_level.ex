defmodule HAP.Characteristics.CurrentAmbientLightLevel do
  @moduledoc """
  Definition of the `public.hap.characteristic.light-level.current` characteristic
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "6B"
  def perms, do: ["pr", "ev"]
  def format, do: "float"
  def min_value, do: 0.0001
  def max_value, do: 100_000
  def units, do: "lux"
end
