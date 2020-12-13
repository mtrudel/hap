defmodule HAP.CharacteristicDefinition do
  @moduledoc """
  A behaviour which encapsulates the functinos required to define a characteristic. 
  At runtime, characteristics are modeled via the `HAP.Characteristic` struct which
  contains the runtime values for the characteristic itself, as well as metadata about
  the characteristic. A `HAP.CharacteristicDefinition` is used to provide the template
  values for these fields. HAP contains definitions for many common HomeKit characteristics
  already, and users may define other characteristics by providing an implemenation of
  this behaviour as the first value in the characteristic definition tuple in a service.
  """

  @doc """
  The HomeKit type code for this characteristic
  """
  @callback type :: HAP.Characteristic.type()

  @doc """
  The permissions to allow for this characteristic
  """
  @callback perms :: HAP.Characteristic.perms()

  @doc """
  The format of this characteristic's data
  """
  @callback format :: HAP.Characteristic.format()

  @doc """
  The minimum value allowed for this characteristic's value
  """
  @callback min_value :: HAP.Characteristic.value()

  @doc """
  The maximum value allowed for this characteristic's value
  """
  @callback max_value :: HAP.Characteristic.value()

  @doc """
  The step size by which this characteristic's value may change
  """
  @callback step_value :: HAP.Characteristic.value()

  @doc """
  The units of this Characteristic's value
  """
  @callback units :: HAP.Characteristic.units()
end
