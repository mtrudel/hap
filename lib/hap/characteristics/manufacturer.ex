defmodule HAP.Characteristics.Manufacturer do
  @moduledoc """
  Factory for the `public.hap.characteristic.manufacturer` characteristic
  """

  def type, do: "20"
  def perms, do: ["pr"]
  def format, do: "string"
  def max_length, do: 64
end
