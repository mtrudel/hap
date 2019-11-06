defmodule HAP.PairVerify do
  @moduledoc """
  Implements the Pair Verify flow described in Apple's [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/). 
  """

  use GenServer

  require Logger

  alias HAP.Accessory

  @kTLVType_Identifier 0x01
  @kTLVType_PublicKey 0x03
  @kTLVType_EncryptedData 0x05
  @kTLVType_State 0x06
  @kTLVType_Error 0x07
  @kTLVType_Signature 0x0A

  @kTLVError_Authentication <<0x02>>
  @kTLVError_Unavailable <<0x06>>

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def handle_message(message, pid \\ __MODULE__) do
    GenServer.call(pid, message)
  end

  def init(_opts) do
    {:ok, %{step: 1}}
  end

  @doc """
  Handles `<M1>` messages and returns `<M2>` messages
  """
  def handle_call(%{@kTLVType_State => <<1>>, @kTLVType_PublicKey => ios_epk}, _from, %{step: 1}) do
    {accessory_epk, accessory_esk} = :crypto.generate_key(:eddsa, :ed25519)
    session_key = :crypto.compute_key(:ecdh, ios_epk, accessory_esk, :x25519)
    accessory_info = accessory_epk <> Accessory.identifier() <> ios_epk
    accessory_signature = :crypto.sign(:eddsa, :sha512, accessory_info, [Accessory.ltsk(), :ed25519])

    resp_sub_tlv =
      %{
        @kTLVType_Identifier => Accessory.identifier(),
        @kTLVType_Signature => accessory_signature
      }
      |> HAP.TLVEncoder.to_binary()

    hashed_k = HKDF.derive(:sha512, session_key, 32, "Pair-Verify-Encrypt-Salt", "Pair-Verify-Encrypt-Info")

    {encrypted_data, auth_tag} =
      :crypto.crypto_one_time_aead(:chacha20_poly1305, hashed_k, 'PV-Msg02', resp_sub_tlv, <<>>, true)

    response = %{
      @kTLVType_State => <<2>>,
      @kTLVType_PublicKey => accessory_epk,
      @kTLVType_EncryptedData => encrypted_data <> auth_tag
    }

    IO.inspect(response)

    {:reply, {:ok, response}, %{step: 3}}
  end

  def handle_message(tlv, _from, state) do
    Logger.error("Received unexpected message for pairing state. Message: #{inspect(tlv)}, state: #{inspect(state)}")
    {:error, "Unexpected message for pairing state"}
  end
end
