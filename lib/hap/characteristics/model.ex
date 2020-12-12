defmodule HAP.Characteristics.Model do
  @moduledoc """
  Factory for the `public.hap.characteristic.model` characteristic
  """

  def type, do: "21"
  def perms, do: ["pr"]
  def format, do: "string"
  def max_length, do: 64
end
