defmodule HAP.Characteristics.StatusActive do
  @moduledoc """
  Definition of the `public.hap.characteristic.status-active` characteristic
  """

  def type, do: "75"
  def perms, do: ["pr", "ev"]
  def format, do: "bool"
end
