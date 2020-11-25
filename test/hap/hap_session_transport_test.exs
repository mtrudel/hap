defmodule HAP.HAPSessionTransportTest do
  use ExUnit.Case

  alias HAP.HAPSessionTransport

  test "can send in the clear & upgrade a live socket to encrypted transport" do
    {:ok, listener_socket} = HAPSessionTransport.listen(0, skip_registration: true)
    %{port: port} = HAPSessionTransport.local_info(listener_socket)

    server_task =
      Task.async(fn ->
        {:ok, server_socket} = HAPSessionTransport.accept(listener_socket)

        {:ok, data} = HAPSessionTransport.recv(server_socket, 0, :infinity)
        HAPSessionTransport.send(server_socket, data)

        HAPSessionTransport.put_send_key(<<1>>)
        HAPSessionTransport.put_recv_key(<<2>>)

        {:ok, data} = HAPSessionTransport.recv(server_socket, 0, :infinity)
        HAPSessionTransport.send(server_socket, data)

        {:ok, data} = HAPSessionTransport.recv(server_socket, 0, :infinity)
        HAPSessionTransport.send(server_socket, data)

        HAPSessionTransport.close(server_socket)
      end)

    {:ok, client_socket} = HAPSessionTransport.connect(:localhost, port, mode: :binary, active: false)

    :ok = HAPSessionTransport.send(client_socket, <<1, 2, 3>>)
    assert {:ok, <<1, 2, 3>>} == HAPSessionTransport.recv(client_socket, 0, :infinity)

    # Note that these are reversed since we're acting as the controller here
    HAPSessionTransport.put_send_key(<<2>>)
    HAPSessionTransport.put_recv_key(<<1>>)

    :ok = HAPSessionTransport.send(client_socket, <<1, 2, 3>>)
    assert {:ok, <<1, 2, 3>>} == HAPSessionTransport.recv(client_socket, 0, :infinity)

    :ok = HAPSessionTransport.send(client_socket, <<1, 2, 3>>)
    assert {:ok, <<1, 2, 3>>} == HAPSessionTransport.recv(client_socket, 0, :infinity)

    Task.await(server_task)
  end

  test "transmits encrypted over the wire when so configured" do
    {:ok, listener_socket} = HAPSessionTransport.listen(0, skip_registration: true)
    %{port: port} = HAPSessionTransport.local_info(listener_socket)

    server_task =
      Task.async(fn ->
        {:ok, server_socket} = HAPSessionTransport.accept(listener_socket)

        HAPSessionTransport.put_send_key(<<1>>)
        HAPSessionTransport.put_recv_key(<<2>>)

        HAPSessionTransport.send(server_socket, <<1, 2, 3>>)

        HAPSessionTransport.close(server_socket)
      end)

    # Connect using a raw TCP socket since we want to test the actual wire
    {:ok, client_socket} = :gen_tcp.connect(:localhost, port, mode: :binary, active: false)

    {encrypted_data, auth_tag} =
      :crypto.crypto_one_time_aead(
        :chacha20_poly1305,
        <<1>>,
        <<0::32, 0::integer-size(64)-little>>,
        <<1, 2, 3>>,
        <<3::integer-size(16)-little>>,
        true
      )

    # Read using raw TCP socket to see *exactly* what is on the wire
    assert {:ok, <<3::integer-size(16)-little, encrypted_data::binary-3, auth_tag::binary-16>>} ==
             :gen_tcp.recv(client_socket, 0, :infinity)

    Task.await(server_task)
  end
end
