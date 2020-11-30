defmodule HAP.Crypto.ECDH do
  @moduledoc false
  # Functions to work with Elliptic Curve Diffie-Hellman shared secret generation

  @type public_key :: binary()
  @type private_key :: binary()
  @type shared_secret :: binary()

  @doc """
  Generates a new ECDH key pair using the `x25519` curve.

  Returns `{:ok, public_key, provate_key}`
  """
  @spec key_gen() :: {:ok, public_key(), private_key()}
  def key_gen do
    {pub, priv} = :crypto.generate_key(:ecdh, :x25519)
    {:ok, pub, priv}
  end

  @doc """
  Computes a shared secret from the counterpary's public key and our private key, using the `x25519` curve.

  Returns `{:ok, shared secret}`
  """
  @spec compute_key(public_key(), private_key()) :: {:ok, shared_secret()}
  def compute_key(other_pub, my_priv) do
    {:ok, :crypto.compute_key(:ecdh, other_pub, my_priv, :x25519)}
  end
end
