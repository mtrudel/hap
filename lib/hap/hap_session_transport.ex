defmodule HAP.HAPSessionTransport do
  @moduledoc false
  # Implements cleartext TCP transport with optional chacha20_poly1305 encryption
  # as mandated by section 6.5.2 of the HomeKit Accessory Protocol specification

  @behaviour ThousandIsland.Transport

  @pair_state_key :pair_state_key
  @send_key_key :hap_send_key
  @recv_key_key :hap_recv_key

  def get_pair_state, do: Process.get(@pair_state_key, HAP.PairVerify.init())
  def put_pair_state(new_state), do: Process.put(@pair_state_key, new_state)
  def put_send_key(send_key), do: Process.put(@send_key_key, send_key)
  def put_recv_key(recv_key), do: Process.put(@recv_key_key, recv_key)

  @impl ThousandIsland.Transport
  def listen(port, options) do
    {hap_options, options} = Keyword.split(options, [:skip_registration])

    with {:ok, listener_socket} <- ThousandIsland.Transports.TCP.listen(port, options) do
      unless Keyword.get(hap_options, :skip_registration) do
        {:ok, {_ip, port}} = :inet.sockname(listener_socket)
        HAP.AccessoryServerManager.set_port(port)
        HAP.Discovery.reload()
      end

      {:ok, listener_socket}
    end
  end

  @impl ThousandIsland.Transport
  defdelegate accept(listener_socket), to: ThousandIsland.Transports.TCP

  @impl ThousandIsland.Transport
  defdelegate handshake(socket), to: ThousandIsland.Transports.TCP

  @impl ThousandIsland.Transport
  defdelegate controlling_process(socket, pid), to: ThousandIsland.Transports.TCP

  @impl ThousandIsland.Transport
  def recv(socket, length, timeout) do
    case ThousandIsland.Transports.TCP.recv(socket, length, timeout) do
      {:ok, data} -> decrypt_if_needed(data)
      other -> other
    end
  end

  @impl ThousandIsland.Transport
  def send(socket, data) do
    case Process.get(@send_key_key) do
      nil ->
        ThousandIsland.Transports.TCP.send(socket, data)

      send_key ->
        with counter <- Process.get(:send_counter, 0),
             nonce <- pad_counter(counter),
             length_aad <- <<IO.iodata_length(data)::integer-size(16)-little>>,
             {:ok, encrypted_data_and_tag} <-
               HAP.Crypto.ChaCha20.encrypt_and_tag(data, send_key, nonce, length_aad) do
          Process.put(:send_counter, counter + 1)
          ThousandIsland.Transports.TCP.send(socket, length_aad <> encrypted_data_and_tag)
        end
    end
  end

  @impl ThousandIsland.Transport
  defdelegate sendfile(socket, filename, offset, length), to: ThousandIsland.Transports.TCP

  @impl ThousandIsland.Transport
  defdelegate getopts(socket, options), to: ThousandIsland.Transports.TCP

  @impl ThousandIsland.Transport
  defdelegate setopts(socket, options), to: ThousandIsland.Transports.TCP

  @impl ThousandIsland.Transport
  defdelegate shutdown(socket, way), to: ThousandIsland.Transports.TCP

  @impl ThousandIsland.Transport
  defdelegate close(socket), to: ThousandIsland.Transports.TCP

  @impl ThousandIsland.Transport
  defdelegate sockname(socket), to: ThousandIsland.Transports.TCP

  @impl ThousandIsland.Transport
  defdelegate peername(socket), to: ThousandIsland.Transports.TCP

  @impl ThousandIsland.Transport
  defdelegate peercert(socket), to: ThousandIsland.Transports.TCP

  @impl ThousandIsland.Transport
  defdelegate secure?(), to: ThousandIsland.Transports.TCP

  @impl ThousandIsland.Transport
  defdelegate getstat(socket), to: ThousandIsland.Transports.TCP

  @impl ThousandIsland.Transport
  defdelegate negotiated_protocol(socket), to: ThousandIsland.Transports.TCP

  def decrypt_if_needed(<<packet::binary>>) do
    case Process.get(@recv_key_key) do
      nil ->
        {:ok, packet}

      recv_key ->
        with <<length::integer-size(16)-little, encrypted_data::binary-size(length), tag::binary-size(16)>> <- packet,
             <<length_aad::binary-size(2), _rest::binary>> <- packet,
             counter <- Process.get(:recv_counter, 0),
             nonce <- pad_counter(counter) do
          Process.put(:recv_counter, counter + 1)
          HAP.Crypto.ChaCha20.decrypt_and_verify(encrypted_data <> tag, recv_key, nonce, length_aad)
        end
    end
  end

  def encrypted_session? do
    !is_nil(Process.get(@recv_key_key)) && !is_nil(Process.get(@send_key_key))
  end

  defp pad_counter(counter) do
    <<0::32, counter::integer-size(64)-little>>
  end
end
