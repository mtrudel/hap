defmodule HAP.ValueStore do
  @callback get_value(keyword()) :: any()
  @callback put_value(any(), keyword()) :: :ok | {:error, String.t()}
end
