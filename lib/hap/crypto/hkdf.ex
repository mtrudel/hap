defmodule HAP.Crypto.HKDF do
  @moduledoc false
  # Functions to help with key derivation

  @type ikm :: binary()
  @type salt :: binary()
  @type info :: binary()
  @type session_key :: binary()

  @doc """
  Generates a session key from provided parameters. Uses the SHA-512 as HMAC

  Returns `{:ok, session_key}`
  """
  @spec generate(ikm(), salt(), info()) :: {:ok, session_key()}
  def generate(ikm, salt, info) do
    {:ok, HKDF.derive(:sha512, ikm, 32, salt, info)}
  end
end
