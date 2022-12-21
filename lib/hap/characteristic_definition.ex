defmodule HAP.CharacteristicDefinition do
  @moduledoc """
  A behaviour which encapsulates the functinos required to define a characteristic. 
  At runtime, characteristics are modeled via the `HAP.Characteristic` struct which
  contains the runtime values for the characteristic itself, as well as metadata about
  the characteristic. A `HAP.CharacteristicDefinition` is used to provide the template
  values for these fields. HAP contains definitions for many common HomeKit characteristics
  already, and users may define other characteristics by providing an implementation of
  this behaviour as the first value in the characteristic definition tuple in a service.
  """

  @typedoc """
  The type of a characteristic as defined in Section 6.6.1 of Apple's [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/).
  """
  @type type :: String.t()

  @typedoc """
  A permission of a characteristic as defined in Table 6.4 of Apple's [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/).
  One of `pr`, `pw`, `ev`, `aa`, `tw`, `hd`, or `wr`
  """
  @type perm :: String.t()

  @typedoc """
  The format of a characteristic as defined in Table 6.5 of Apple's [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/).
  One of `bool`, `uint8`, `uint16`, `uint32`, `uint64`, `int`, `float`, `string`, `tlv8`, or `data`
  """
  @type format :: String.t()

  @typedoc """
  The unit of measure of a characrteristic's value
  """
  @type unit :: any()

  @doc """
  The HomeKit type code for this characteristic
  """
  @callback type :: type()

  @doc """
  The permissions to allow for this characteristic
  """
  @callback perms :: [perm()]

  @doc """
  The format of this characteristic's data
  """
  @callback format :: format()

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
  @callback units :: unit()

  @doc """
  Whether or not to only return values via events. Required mostly to satisfy the somewhat oddball *Programmable Switch Event*
  characteristic as defined in section 9.75 of Apple's [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/).
  """
  @callback event_only :: boolean()

  @optional_callbacks min_value: 0, max_value: 0, step_value: 0, units: 0, event_only: 0
end
