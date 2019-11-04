defmodule HAP.Crypto.EDDSA do
  def key_gen do
    :crypto.generate_key(:eddsa, :ed25519)
  end

  def sign(message, key) do
    {:ok, :crypto.sign(:eddsa, :sha512, message, [key, :ed25519])}
  end

  def verify(message, signature, key) do
    :crypto.verify(:eddsa, :sha512, message, signature, [key, :ed25519])
  end
end
