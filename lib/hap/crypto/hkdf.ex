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
    # Taken from https://github.com/jschneider1207/hkdf/pull/3. Review if/when the
    # referenced PR lands
    prk = :crypto.mac(:hmac, :sha512, salt, ikm)

    hash_len = :crypto.hash(:sha512, "") |> byte_size()
    n = Float.ceil(32 / hash_len) |> round()

    full =
      Enum.scan(1..n, "", fn index, prev ->
        data = prev <> info <> <<index>>
        :crypto.mac(:hmac, :sha512, prk, data)
      end)
      |> Enum.reduce("", &Kernel.<>(&2, &1))

    <<output::unit(8)-size(32), _::binary>> = full
    {:ok, <<output::unit(8)-size(32)>>}
  end
end
