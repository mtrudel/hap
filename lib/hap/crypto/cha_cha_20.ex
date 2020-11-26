defmodule HAP.Crypto.ChaCha20 do
  @moduledoc """
  Functions to encrypt/tag and decrypt/verify using the chacha20_poly1305 cipher
  """

  @type plaintext :: binary()
  @type ciphertext_with_authdata :: binary()
  @type key :: <<_::256>>
  @type nonce :: binary()
  @type aad :: binary()

  @doc """
  Takes a binary containing encrypted data followed by a 16 byte tag, verifies the tag
  and decrypts the resultant data using the given key and nonce. Can take optional AAD
  data which is authenticated under the auth_tag but not encrypted. 

  Returns `{:ok, plaintext}` or `{:error, message}`
  """
  @spec decrypt_and_verify(ciphertext_with_authdata(), key(), nonce(), aad()) ::
          {:ok, plaintext()} | {:error, String.t()}
  def decrypt_and_verify(encrypted_data, key, nonce, aad \\ <<>>) do
    encrypted_data_length = byte_size(encrypted_data) - 16
    <<encrypted_data::binary-size(encrypted_data_length), auth_tag::binary-16>> = encrypted_data

    case :crypto.crypto_one_time_aead(:chacha20_poly1305, key, nonce, encrypted_data, aad, auth_tag, false) do
      :error -> {:error, "Message decryption error"}
      result -> {:ok, result}
    end
  end

  @doc """
  Takes a plaintext binary and encrypts & tags it using the given key & nonce. Optionally takes
  AAD data which is authenticated under the auth tag but not included in the returned binary (it is
  up to the caller to convey the AAD to their counterparty). 

  Returns `{:ok, encrypted_data <> auth_tag}`
  """
  @spec encrypt_and_tag(plaintext(), key(), nonce(), aad()) :: {:ok, ciphertext_with_authdata()}
  def encrypt_and_tag(plaintext, key, nonce, aad \\ <<>>) do
    {encrypted_data, auth_tag} = :crypto.crypto_one_time_aead(:chacha20_poly1305, key, nonce, plaintext, aad, true)
    {:ok, encrypted_data <> auth_tag}
  end
end
