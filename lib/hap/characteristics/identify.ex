defmodule HAP.Characteristics.Identify do
  @moduledoc """
  Factory for the `public.hap.characteristic.identify` characteristic
  """

  def type, do: "14"
  def perms, do: ["pw"]
  def format, do: "bool"
end
