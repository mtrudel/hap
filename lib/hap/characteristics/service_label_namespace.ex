defmodule HAP.Characteristics.ServiceLabelNamespace do
  @moduledoc """
  Definition of the `public.hap.characteristic.service-label-namespace` characteristic

  Valid Values
  0 ”Dots. For e.g ”.” ”..” ”...” ”....””
  1 ”Arabic numerals. For e.g. 0,1,2,3”

  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "CD"
  def perms, do: ["pr"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 1
  def step_value, do: 1
end
