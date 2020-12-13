defmodule HAP.Characteristics.Version do
  @moduledoc """
  Definition of the `public.hap.characteristic.version` characteristic
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "37"
  def perms, do: ["pr"]
  def format, do: "string"
  def max_length, do: 64
end
