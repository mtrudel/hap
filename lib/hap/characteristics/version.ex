defmodule HAP.Characteristics.Version do
  @moduledoc """
  Factory for the `public.hap.characteristic.version` characteristic
  """

  def type, do: "37"
  def perms, do: ["pr"]
  def format, do: "string"
  def max_length, do: 64
end
