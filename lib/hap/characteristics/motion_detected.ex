defmodule HAP.Characteristics.MotionDetected do
  @moduledoc """
  Definition of the `public.hap.characteristic.motion-detected` characteristic
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "22"
  def perms, do: ["pr", "ev"]
  def format, do: "bool"
end
