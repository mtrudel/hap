defmodule HAP.Crypto.ECDH do
  @moduledoc """
  Functions to generate keypairs / session keys using Elliptic Curve Diffie-Hellman shared secret generation
  """

  def key_gen do
    {pub, priv} = :crypto.generate_key(:ecdh, :x25519)
    {:ok, pub, priv}
  end

  def compute_key(other_pub, my_priv) do
    {:ok, :crypto.compute_key(:ecdh, other_pub, my_priv, :x25519)}
  end
end
