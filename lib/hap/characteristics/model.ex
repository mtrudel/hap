defmodule HAP.Characteristics.Model do
  @moduledoc """
  Definition of the `public.hap.characteristic.model` characteristic
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "21"
  def perms, do: ["pr"]
  def format, do: "string"
  def max_length, do: 64
end
