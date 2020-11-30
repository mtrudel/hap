defmodule HAP.Crypto.EDDSA do
  @moduledoc false
  # Functions to generate keys, sign & verify messages using Elliptic Curve Signatures

  @type plaintext :: binary()
  @type public_key :: binary()
  @type private_key :: binary()
  @type signature :: binary()

  @doc """
  Generates a new signing key pair using the `ed25519` signature scheme.

  Returns `{:ok, public_key, private_key}`
  """
  @spec key_gen() :: {:ok, public_key(), private_key()}
  def key_gen do
    {pub, priv} = :crypto.generate_key(:eddsa, :ed25519)
    {:ok, pub, priv}
  end

  @doc """
  Signs the given message with the given `ed25519` private key.

  Returns `{:ok, signature}`
  """
  @spec sign(plaintext(), private_key()) :: {:ok, signature()}
  def sign(message, key) do
    {:ok, :crypto.sign(:eddsa, :sha512, message, [key, :ed25519])}
  end

  @doc """
  Verifies that the given signature signs the given message under the key specified.

  Returns `{:ok, true}` or `{:ok, false}`
  """
  @spec verify(plaintext(), signature(), public_key()) :: {:ok, boolean()}
  def verify(message, signature, key) do
    {:ok, :crypto.verify(:eddsa, :sha512, message, signature, [key, :ed25519])}
  end
end
