defmodule HAP.Crypto.SHA512 do
  def hash(x), do: :crypto.hash(:sha512, x)
end
