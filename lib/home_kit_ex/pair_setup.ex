defmodule HomeKitEx.PairSetup do
  @moduledoc """
  Implements the Pair Setup flow described in section 4.7 of Apple's [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/). 
  """

  use Bitwise

  @kTLVType_Method 0x00
  @kTLVType_Salt 0x02
  @kTLVType_PublicKey 0x03
  @kTLVType_Proof 0x04
  @kTLVType_State 0x06
  @kTLVType_Error 0x07

  @kTLVError_Authentication <<0x02>>

  @doc """
  Handles `<M1>` messages and returns `<M2>` messages
  """
  def handle_message(%{@kTLVType_State => <<1>>, @kTLVType_Method => <<0>>}, _state) do
    username = "Pair-Setup"
    {prime, group} = Strap.prime_group(3072)
    protocol = Strap.protocol(:srp6a, prime, group, :sha512)
    salt = :crypto.strong_rand_bytes(16)
    verifier = Strap.verifier(protocol, username, "111-22-333", salt)
    server = Strap.server(protocol, verifier)
    public = Strap.public_value(server)

    # TODO better errors & parameterization of above

    response = %{
      @kTLVType_State => <<2>>,
      @kTLVType_PublicKey => public,
      @kTLVType_Salt => salt
    }

    new_pairing_state = %{
      server: server,
      prime: prime,
      group: group,
      username: username,
      salt: salt,
      verifier: verifier
    }

    {:ok, response, new_pairing_state}
  end

  @doc """
  Handles `<M3>` messages and returns `<M4>` messages
  """
  def handle_message(%{@kTLVType_State => <<3>>, @kTLVType_PublicKey => client_public_key, @kTLVType_Proof => proof}, %{
        server: server,
        prime: prime,
        group: group,
        username: username,
        salt: salt
      }) do
    {:ok, shared_key} = Strap.session_key(server, client_public_key)

    # M_1 = H(H(N) xor H(g), H(I), s, A, B, K)

    hashed_prime = prime |> hash |> to_int
    hashed_group = group |> to_bin |> hash |> to_int
    xor = bxor(hashed_prime, hashed_group) |> to_bin

    hashed_identity = username |> hash
    server_public_key = server |> Strap.public_value()
    hashed_shared_key = shared_key |> hash

    my_proof = hash(xor <> hashed_identity <> salt <> client_public_key <> server_public_key <> hashed_shared_key)

    response =
      case proof do
        ^my_proof ->
          %{
            @kTLVType_State => <<4>>,
            @kTLVType_Proof => hash(client_public_key <> my_proof <> hashed_shared_key)
          }

        _ ->
          %{
            @kTLVType_State => <<4>>,
            @kTLVType_Error => @kTLVError_Authentication
          }
      end

    new_pairing_state = %{}
    {:ok, response, new_pairing_state}
  end

  def handle_message(%{@kTLVType_State => <<5>>} = request, _) do
    IO.inspect(request)

    response = %{@kTLVType_State => <<6>>}
    new_pairing_state = %{}
    {:ok, response, new_pairing_state}
  end

  # TODO return proper errors per 5.6.2.{1,2,3}
  def handle_message(_tlv, _pairing_state) do
    {:error, "Invalid pairing state"}
  end

  defp hash(x), do: :crypto.hash(:sha512, x)
  defp to_bin(val) when is_integer(val), do: :binary.encode_unsigned(val)
  defp to_int(val) when is_bitstring(val), do: :binary.decode_unsigned(val)
end
