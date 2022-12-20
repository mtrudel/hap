defmodule HAP.Characteristics.Mute do
  @moduledoc """
  Definition of the `public.hap.characteristic.mute` characteristic
  # Valid Values
  #
  # 0 ”Mute is Off / Audio is On”
  # 1 ”Mute is On / There is no Audio”

  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "11A"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "bool"
end
