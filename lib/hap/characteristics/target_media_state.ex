defmodule HAP.Characteristics.TargetMediaState do
  @moduledoc """
  Definition of the `public.hap.characteristic.target-media-state` characteristic

  Valid values:
  0 - Play
  1 - Pause
  2 - Stop

  Used to control the playback state of media on the television.
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "137"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 2
  def step_value, do: 1
end
