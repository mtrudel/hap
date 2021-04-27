defmodule HAP.ValueStore do
  @moduledoc """
  Defines the behaviour required of a module that wishes to act as the backing data store
  for a given HomeKit characteristic
  """

  @type t :: module()
  @type opts :: keyword()
  @opaque change_token :: {term(), term()}

  @doc """
  Return the value of a value hosted by this value store. The passed list of opts
  is as specified in the hosting `HAP.Configuration` and can be used to distinguish a
  particular value within a larger value store (perhaps by GPIO pin or similar)

  Returns the value stored by this value store
  """
  @callback get_value(opts :: opts()) :: {:ok, HAP.Characteristic.value()} | {:error, String.t()}

  @doc """

  Sets the value of a value hosted by this value store. The passed list of opts
  is as specified in the hosting `HAP.Configuration` and can be used to distinguish a
  particular value within a larger value store (perhaps by GPIO pin or similar)

  Returns `:ok` or `{:error, reason}`
  """
  @callback put_value(value :: HAP.Characteristic.value(), opts :: opts()) :: :ok | {:error, String.t()}

  @doc """

  Informs the value store of the change token to use when notifying HAP of asynchronous 
  changes to the value in this store. This token should be provided to `HAP.value_changed/1` as the 
  sole argument; HAP will make a subsequent call to `c:get_value/1` to obtain the changed value

  Returns `:ok` or `{:error, reason}`
  """
  @callback set_change_token(change_token :: change_token(), opts :: opts()) :: :ok | {:error, String.t()}

  @optional_callbacks set_change_token: 2
end
