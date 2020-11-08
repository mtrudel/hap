defmodule HAP.Crypto.ChaCha20 do
  def decrypt_and_verify(encrypted_data, key, nonce, aad \\ <<>>) do
    encrypted_data_length = byte_size(encrypted_data) - 16
    <<encrypted_data::binary-size(encrypted_data_length), auth_tag::binary-16>> = encrypted_data

    case :crypto.crypto_one_time_aead(:chacha20_poly1305, key, nonce, encrypted_data, aad, auth_tag, false) do
      :error -> {:error, "Message decryption error"}
      result -> {:ok, result}
    end
  end

  def encrypt_and_tag(plaintext, key, nonce, aad \\ <<>>) do
    {encrypted_data, auth_tag} = :crypto.crypto_one_time_aead(:chacha20_poly1305, key, nonce, plaintext, aad, true)
    {:ok, encrypted_data <> auth_tag}
  end
end
