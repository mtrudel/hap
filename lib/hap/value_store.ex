defmodule HAP.ValueStore do
  @moduledoc """
  Defines the behaviour required of a module that wishes to act as the backing data store
  for a given HomeKit characteristic

  # Simple Value Store

  To implement a value store for a simple value whose value does not change asynchronously,
  you must implement the `c:get_value/1` and `c:put_value/2` callbacks. These callbacks each 
  take a set of opts (specified in the initial configuration passed to `HAP.start_link/1`) to
  allow your implementation to discriminate between various values within the same `HAP.ValueStore` 
  module.

  # Supporting Asynchronous Notifications

  To support notifying HomeKit of changes to an accessory's characteristics (such as a user pressing
  a button or a flood sensor detecting water), implementations of `HAP.ValueStore` may choose to 
  implement the optional `c:set_change_token/2` callback. This callback will provide your implementation
  with a change token to use when notifying HAP of changes to the corresponding value. To notify HAP of
  changes to a value, pass this change token to the `HAP.value_changed/1` function. HAP will then query 
  your value store for the new value of the corresponding characteristic and notify any HomeKit controllers
  of the change.

  There are a number of things to be aware of when using Asynchronous Notifications:

  * Your value store must be prepared to answer calls to `c:get_value/1` with the updated value before
  calling `HAP.value_changed/1`.
  * Do not call `HAP.value_changed/1` to notify HAP of changes which come from HAP itself (ie: do not call it in the course 
  of implementing `c:put_value/2`). Use it only for notifying HAP of changes which are truly asynchronous.
  * If you have not yet received a `c:set_change_token/2` call, then you should not call `HAP.value_changed/1`; HAP will only
  provide you with a change token for characteristics which a HomeKit controller has requested notifications on. Specifically, 
  do not retain change tokens between runs; they should maintain the same lifetime as the underlying HAP process.
  * The call to `HAP.value_changed/1` is guaranteed to return quickly. It does no work beyond casting a message
  to HAP to set the notification process in motion.
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
