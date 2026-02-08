defmodule HAP.Characteristics.TargetHeatingCoolingState do
  @moduledoc """
  Definition of the `public.hap.characteristic.heating-cooling.state.target` characteristic

  Valid values:

  0 Off
  1 Heat (if current temperature is below the target temperature then turn on heating)
  2 Cooling (if current temperature is above the target temperature then turn on cooling)
  3 Auto (either heating or cooling as appropriate)
  """

  @behaviour HAP.CharacteristicDefinition

  def type, do: "33"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "uint8"
  def min_value, do: 0
  def max_value, do: 3
  def step_value, do: 1
end
