defmodule HAP.Characteristics.On do
  @moduledoc """
  Definition of the `public.hap.characteristic.on` characteristic
  """

  def type, do: "25"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "bool"
end
