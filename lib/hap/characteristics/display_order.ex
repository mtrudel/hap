defmodule HAP.Characteristics.DisplayOrder do
  @moduledoc """
  Definition of the `public.hap.characteristic.display-order` characteristic

  Represents the display order of input sources. This is used to determine
  the order in which input sources are displayed in the Home app.

  The value is a base64-encoded TLV8 structure containing the ordered
  identifiers of the input sources.
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "136"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "tlv8"
end
