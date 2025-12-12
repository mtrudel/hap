defmodule HAP.Characteristics.PictureMode do
  @moduledoc """
  Definition of the `public.hap.characteristic.picture-mode` characteristic

  Valid values:
  0 - Other
  1 - Standard
  2 - Calibrated
  3 - Calibrated Dark
  4 - Vivid
  5 - Game
  6 - Computer
  7 - Custom

  Controls the picture mode/preset of the television display.
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "E2"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 13
  def step_value, do: 1
end
