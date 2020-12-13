defmodule HAP.Characteristics.Identify do
  @moduledoc """
  Definition of the `public.hap.characteristic.identify` characteristic
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "14"
  def perms, do: ["pw"]
  def format, do: "bool"
end
