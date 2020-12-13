defmodule HAP.Characteristics.Manufacturer do
  @moduledoc """
  Definition of the `public.hap.characteristic.manufacturer` characteristic
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "20"
  def perms, do: ["pr"]
  def format, do: "string"
  def max_length, do: 64
end
