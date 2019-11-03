defmodule HAP.Crypto.SRP6A do
  use Bitwise

  def verifier(i, p) do
    s = :crypto.strong_rand_bytes(16)
    v = Strap.verifier(protocol(), i, p, s)
    {s, v}
  end

  def auth_context(v) do
    server = Strap.server(protocol(), v)
    {server, Strap.public_value(server)}
  end

  def shared_key(auth_context, a, i, s) do
    # Generate k
    {:ok, shared_key} = Strap.session_key(auth_context, a)
    k = shared_key |> hash

    # Generate M_1
    # M_1 = H(H(N) xor H(g), H(I), s, A, B, K)
    {n, g} = prime_group()
    h_n = n |> hash |> to_int
    h_g = g |> to_bin |> hash |> to_int
    xor = bxor(h_n, h_g) |> to_bin
    h_i = i |> hash
    b = auth_context |> Strap.public_value()
    m_1 = hash(xor <> h_i <> s <> a <> b <> k)

    # Generate M_2
    # M_2 = H(A, M_1, K)
    m_2 = hash(a <> m_1 <> k)

    {m_1, m_2, k}
  end

  defp protocol do
    {n, g} = prime_group()
    Strap.protocol(:srp6a, n, g, :sha512)
  end

  defp prime_group do
    Strap.prime_group(3072)
  end

  defp hash(x), do: :crypto.hash(:sha512, x)
  defp to_bin(val) when is_integer(val), do: :binary.encode_unsigned(val)
  defp to_int(val) when is_bitstring(val), do: :binary.decode_unsigned(val)
end
