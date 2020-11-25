defmodule HAP.HAPSessionTransport do
  @moduledoc """
  Implements cleartext TCP transport with optional chacha20_poly1305 encryption
  as mandated by section 6.5.2 of the HomeKit Accessory Protocol specification
  """

  alias HAP.Crypto.ChaCha20
  alias ThousandIsland.Transport

  @behaviour Transport

  @pair_state_key :pair_state_key
  @send_key_key :hap_send_key
  @recv_key_key :hap_recv_key
  @hardcoded_options [mode: :binary, active: false]

  def get_pair_state, do: Process.get(@pair_state_key, HAP.PairVerify.init())
  def put_pair_state(new_state), do: Process.put(@pair_state_key, new_state)

  def put_send_key(send_key) do
    Process.put(@send_key_key, send_key)
  end

  def put_recv_key(recv_key) do
    Process.put(@recv_key_key, recv_key)
  end

  @impl Transport
  def listen(port, user_options) do
    default_options = [
      backlog: 1024,
      nodelay: true,
      linger: {true, 30},
      send_timeout: 30_000,
      send_timeout_close: true,
      reuseaddr: true
    ]

    {hap_options, user_options} = Keyword.split(user_options, [:skip_registration])

    resolved_options = default_options |> Keyword.merge(user_options) |> Keyword.merge(@hardcoded_options)

    :telemetry.execute(
      [:transport, :listen, :start],
      %{port: port, options: resolved_options, transport: :tcp},
      %{}
    )

    with {:ok, listener_socket} <- :gen_tcp.listen(port, resolved_options) do
      unless Keyword.get(hap_options, :skip_registration) do
        {:ok, {_ip, port}} = :inet.sockname(listener_socket)
        HAP.AccessoryServerManager.set_port(port)
        HAP.Discovery.reload()
      end

      {:ok, listener_socket}
    end
  end

  @impl Transport
  defdelegate listen_port(listener_socket), to: :inet, as: :port

  @impl Transport
  defdelegate accept(listener_socket), to: :gen_tcp

  @impl Transport
  def handshake(socket), do: {:ok, socket}

  @impl Transport
  defdelegate controlling_process(socket, pid), to: :gen_tcp

  @impl Transport
  def recv(socket, length, timeout) do
    case Process.get(@recv_key_key) do
      nil ->
        :gen_tcp.recv(socket, length, timeout)

      recv_key ->
        with {:ok, <<packet::binary>>} <- :gen_tcp.recv(socket, length, timeout),
             <<length::integer-size(16)-little, encrypted_data::binary-size(length), tag::binary-size(16)>> <- packet,
             <<length_aad::binary-size(2), _rest::binary>> <- packet,
             counter <- Process.get(:recv_counter, 0),
             nonce <- pad_counter(counter) do
          Process.put(:recv_counter, counter + 1)
          ChaCha20.decrypt_and_verify(encrypted_data <> tag, recv_key, nonce, length_aad)
        else
          error ->
            error
        end
    end
  end

  @impl Transport
  def send(socket, data) do
    case Process.get(@send_key_key) do
      nil ->
        :gen_tcp.send(socket, data)

      send_key ->
        with counter <- Process.get(:send_counter, 0),
             nonce <- pad_counter(counter),
             length_aad <- <<IO.iodata_length(data)::integer-size(16)-little>>,
             {:ok, encrypted_data_and_tag} <-
               ChaCha20.encrypt_and_tag(data, send_key, nonce, length_aad) do
          Process.put(:send_counter, counter + 1)
          :gen_tcp.send(socket, length_aad <> encrypted_data_and_tag)
        else
          error ->
            error
        end
    end
  end

  @impl Transport
  def sendfile(_socket, _filename, _offset, _length) do
    raise "Not supported"
  end

  @impl Transport
  def setopts(socket, options) do
    resolved_options = Keyword.merge(options, @hardcoded_options)
    :inet.setopts(socket, resolved_options)
  end

  @impl Transport
  defdelegate shutdown(socket, way), to: :gen_tcp

  @impl Transport
  defdelegate close(socket), to: :gen_tcp

  @impl Transport
  def local_info(socket) do
    {:ok, {ip_tuple, port}} = :inet.sockname(socket)
    ip = ip_tuple |> :inet.ntoa() |> to_string()
    %{address: ip, port: port, ssl_cert: nil}
  end

  @impl Transport
  def peer_info(socket) do
    {:ok, {ip_tuple, port}} = :inet.peername(socket)
    ip = ip_tuple |> :inet.ntoa() |> to_string()
    %{address: ip, port: port, ssl_cert: nil}
  end

  @impl Transport
  defdelegate getstat(socket), to: :inet

  @doc """
  Returns true iff the current process is in an encrypted session
  """
  def encrypted_session? do
    !is_nil(Process.get(@recv_key_key)) && !is_nil(Process.get(@send_key_key))
  end

  @doc """
  Helpful in tests when we need to act as the iOS Controller in a HAP Session
  """
  defdelegate connect(host, port, opts), to: :gen_tcp

  defp pad_counter(counter) do
    <<0::32, counter::integer-size(64)-little>>
  end
end
