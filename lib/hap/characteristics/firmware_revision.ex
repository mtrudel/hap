defmodule HAP.Characteristics.FirmwareRevision do
  @moduledoc """
  Definition of the `public.hap.characteristic.firmware.revision` characteristic
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "52"
  def perms, do: ["pr"]
  def format, do: "string"
end
