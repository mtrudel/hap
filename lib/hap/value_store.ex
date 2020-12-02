defmodule HAP.ValueStore do
  @moduledoc """
  Defines the behaviour required of a module that wishes to act as the backing data store
  for a given HomeKit characteristic
  """

  @type t :: module()
  @type opts :: keyword()

  @doc """
  Return the value of a value hosted by this value store. The passed list of opts
  is as specified in the hosting `HAP.Configuration` and can be used to distinguish a
  particular value within a larger value store (perhaps by GPIO pin or similar)

  Returns the value stored by this value store
  """
  @callback get_value(opts :: opts()) :: HAP.Characteristic.value()

  @doc """

  Sets the value of a value hosted by this value store. The passed list of opts
  is as specified in the hosting `HAP.Configuration` and can be used to distinguish a
  particular value within a larger value store (perhaps by GPIO pin or similar)

  Returns `:ok` or `{:error, reason}`
  """
  @callback put_value(value :: HAP.Characteristic.value(), opts :: opts()) :: :ok | {:error, String.t()}
end
