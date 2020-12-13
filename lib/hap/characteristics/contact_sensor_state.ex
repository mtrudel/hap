defmodule HAP.Characteristics.ContactSensorState do
  @moduledoc """
  Definition of the `public.hap.characteristic.contact-state` characteristic

  A value of 0 indicates that the contact is detected. A value of 1 indicates 
  that the contact is not detected.
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "6A"
  def perms, do: ["pr", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 1
  def step_value, do: 1
end
