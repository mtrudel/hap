defmodule HAP.Characteristics.SerialNumber do
  @moduledoc """
  Definition of the `public.hap.characteristic.serial-number` characteristic
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "30"
  def perms, do: ["pr"]
  def format, do: "string"
  def max_length, do: 64
end
