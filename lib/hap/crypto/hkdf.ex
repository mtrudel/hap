defmodule HAP.Crypto.HKDF do
  def generate(session_key, salt, info) do
    HKDF.derive(:sha512, session_key, 32, salt, info)
  end
end
