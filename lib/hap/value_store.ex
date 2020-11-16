defmodule HAP.ValueStore do
  @moduledoc """
  Defines the behaviour required of a module that wishes to act as the backing data store
  for a given HomeKit characteristic
  """

  @callback get_value(keyword()) :: any()
  @callback put_value(any(), keyword()) :: :ok | {:error, String.t()}
end
