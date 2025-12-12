defmodule HAP.Characteristics.CurrentMediaState do
  @moduledoc """
  Definition of the `public.hap.characteristic.current-media-state` characteristic

  Valid values:
  0 - Play
  1 - Pause
  2 - Stop
  3 - Unknown

  Represents the current playback state of media on the television.
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "E0"
  def perms, do: ["pr", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 3
  def step_value, do: 1
end
