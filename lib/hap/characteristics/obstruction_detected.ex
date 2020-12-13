defmodule HAP.Characteristics.ObstructionDetected do
  @moduledoc """
  Definition of the `public.hap.characteristic.obstruction-detected` characteristic
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "24"
  def perms, do: ["pr", "ev"]
  def format, do: "bool"
end
