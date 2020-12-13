defmodule HAP.Characteristics.FirmwareRevision do
  @moduledoc """
  Definition of the `public.hap.characteristic.firmware.revision` characteristic
  """

  def type, do: "52"
  def perms, do: ["pr"]
  def format, do: "string"
end
