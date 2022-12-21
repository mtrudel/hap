defmodule HAP.Characteristics.ServiceLabelIndex do
  @moduledoc """
  Definition of the `public.hap.characteristic.service-label-index` characteristic

  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "CB"
  def perms, do: ["pr"]
  def format, do: "uint8"
  def min_value, do: 1
  def step_value, do: 1
end
