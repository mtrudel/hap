defmodule HAP.Characteristics.Active do
  @moduledoc """
  Definition of the `public.hap.characteristic.active` characteristic
  """

  def type, do: "B0"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 1
  def step_value, do: 1
end
