defmodule HAP.Characteristics.TargetHeaterCoolerState do
  @moduledoc """
  Definition of the `public.hap.characteristic.heater-cooler.target` characteristic

  Valid values: 

  0 Off
  1 Heat (if current temperature is below the target temperature then turn on heating)
  2 Cooling (if current temperature is above the target temperature then turn on cooling)
  3 Auto (turn on heating or cooling to maintain temperature within the target temperatures)
  """

  def type, do: "33"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 3
  def step_unit, do: 1
end
