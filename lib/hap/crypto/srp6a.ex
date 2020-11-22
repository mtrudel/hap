defmodule HAP.Crypto.SRP6A do
  @moduledoc """
  Implements the various steps within the Stanford Remote Password (version 6a) flow
  """

  use Bitwise

  alias HAP.Crypto.SHA512

  def verifier(i, p) do
    s = :crypto.strong_rand_bytes(16)
    v = Strap.verifier(protocol(), i, p, s)
    {:ok, s, v}
  end

  def auth_context(v) do
    server = Strap.server(protocol(), v)
    {:ok, server, Strap.public_value(server)}
  end

  def client(username, password, salt) do
    client = Strap.client(protocol(), username, password, salt)
    {:ok, client, Strap.public_value(client)}
  end

  # TODO - this should go upstream. See https://github.com/twooster/strap/issues/2
  def shared_key({:server, _, _, _, _} = auth_context, a, i, s) do
    # Generate k
    {:ok, shared_key} = Strap.session_key(auth_context, a)
    k = shared_key |> SHA512.hash()

    # Generate M_1
    # M_1 = H(H(N) xor H(g), H(I), s, A, B, K)
    {n, g} = prime_group()
    h_n = n |> SHA512.hash() |> to_int
    h_g = g |> to_bin |> SHA512.hash() |> to_int
    xor = bxor(h_n, h_g) |> to_bin
    h_i = i |> SHA512.hash()
    b = auth_context |> Strap.public_value()
    m_1 = SHA512.hash(xor <> h_i <> s <> a <> b <> k)

    # Generate M_2
    # M_2 = H(A, M_1, K)
    m_2 = SHA512.hash(a <> m_1 <> k)

    {:ok, m_1, m_2, k}
  end

  def shared_key({:client, _, _, _, _} = auth_context, b, i, s) do
    # Generate k
    {:ok, shared_key} = Strap.session_key(auth_context, b)
    k = shared_key |> SHA512.hash()

    # Generate M_1
    # M_1 = H(H(N) xor H(g), H(I), s, A, B, K)
    {n, g} = prime_group()
    h_n = n |> SHA512.hash() |> to_int
    h_g = g |> to_bin |> SHA512.hash() |> to_int
    xor = bxor(h_n, h_g) |> to_bin
    h_i = i |> SHA512.hash()
    a = auth_context |> Strap.public_value()
    m_1 = SHA512.hash(xor <> h_i <> s <> a <> b <> k)

    # Generate M_2
    # M_2 = H(A, M_1, K)
    m_2 = SHA512.hash(a <> m_1 <> k)

    {:ok, m_1, m_2, k}
  end

  defp protocol do
    {n, g} = prime_group()
    Strap.protocol(:srp6a, n, g, :sha512)
  end

  defp prime_group do
    Strap.prime_group(3072)
  end

  defp to_bin(val) when is_integer(val), do: :binary.encode_unsigned(val)
  defp to_int(val) when is_bitstring(val), do: :binary.decode_unsigned(val)
end
