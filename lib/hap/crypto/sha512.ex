defmodule HAP.Crypto.SHA512 do
  @moduledoc """
  Simple wrapper around Erlang's `:crypto.hash()` function
  """

  def hash(x), do: :crypto.hash(:sha512, x)
end
