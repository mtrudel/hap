defmodule HAP.Characteristics.HoldPosition do
  @moduledoc """
  Definition of the `public.hap.characteristic.position.hold` characteristic
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "6F"
  def perms, do: ["pw"]
  def format, do: "bool"
end
