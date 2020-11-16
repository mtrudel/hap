defmodule HAP.Crypto.EDDSA do
  @moduledoc """
  Functions to generate keys, sign & verify messages using Elliptic Curve Signatures
  """

  def key_gen do
    {pub, priv} = :crypto.generate_key(:eddsa, :ed25519)
    {:ok, pub, priv}
  end

  def sign(message, key) do
    {:ok, :crypto.sign(:eddsa, :sha512, message, [key, :ed25519])}
  end

  def verify(message, signature, key) do
    {:ok, :crypto.verify(:eddsa, :sha512, message, signature, [key, :ed25519])}
  end
end
