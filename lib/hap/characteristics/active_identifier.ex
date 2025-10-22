defmodule HAP.Characteristics.ActiveIdentifier do
  @moduledoc """
  Definition of the `public.hap.characteristic.active-identifier` characteristic

  This characteristic is used to represent the currently active input source
  on the television. The value corresponds to the identifier of the selected
  input source.
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "E7"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "uint32"
  def min_value, do: 0
end