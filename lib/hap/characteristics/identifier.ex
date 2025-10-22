defmodule HAP.Characteristics.Identifier do
  @moduledoc """
  Definition of the `public.hap.characteristic.identifier` characteristic

  A unique identifier for the input source. This value is used to reference
  this input source from the ActiveIdentifier characteristic of the Television
  service.
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "E6"
  def perms, do: ["pr", "ev"]
  def format, do: "uint32"
  def min_value, do: 0
end