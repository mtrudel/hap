defmodule HAP.Characteristics.Name do
  @moduledoc """
  Definition of the `public.hap.characteristic.name` characteristic
  """

  def type, do: "23"
  def perms, do: ["pr"]
  def format, do: "string"
  def max_length, do: 64
end
