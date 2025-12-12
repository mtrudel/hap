defmodule HAP.Characteristics.ConfiguredName do
  @moduledoc """
  Definition of the `public.hap.characteristic.configured-name` characteristic

  This characteristic allows the user to provide a custom name for the accessory
  or service. This is typically used for input sources on a television to allow
  custom naming like "Cable Box" or "Game Console".
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "E3"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "string"
end
