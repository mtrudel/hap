defmodule HAP.Characteristics.FirmwareRevision do
  @moduledoc """
  Factory for the `public.hap.characteristic.firmware.revision` characteristic
  """

  def type, do: "52"
  def perms, do: ["pr"]
  def format, do: "string"
end
