defmodule HAP.Characteristics.CurrentHeaterCoolerState do
  @moduledoc """
  Factory for the `public.hap.characteristic.heater-cooler.state.current` characteristic

  Valid values:

  0 Inactive
  1 Idle
  2 Heating
  3 Cooling
  """

  def type, do: "B1"
  def perms, do: ["pr", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 3
  def step_unit, do: 1
end
