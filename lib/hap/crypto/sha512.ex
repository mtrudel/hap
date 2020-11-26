defmodule HAP.Crypto.SHA512 do
  @moduledoc """
  Simple wrapper around Erlang's `:crypto.hash()` function
  """

  @type message :: binary()
  @type hash :: binary()

  @doc """
  Returns the SHA-512 has of the given message.

  Returns the hash directly (not contained in a success tuple)
  """
  @spec hash(message()) :: hash()
  def hash(x), do: :crypto.hash(:sha512, x)
end
