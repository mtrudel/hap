defmodule HAP.HAPSessionHandler do
  @moduledoc false
  # A thin wrapper around Bandit's HTTP1 support, which does two things:
  #
  # 1. HAP requires socket-level encryption at least part of the time. This handler implementation
  #    shims such support into the `c:handle_data/3` callback
  # 2. Provides for the ability to send async (and non-standard) `EVENT` messages to a client

  use ThousandIsland.Handler

  # Push an asynchronous message to the client as described in section 6.8 of the
  # HomeKit Accessory Protocol specification
  def push(pid, data) do
    GenServer.cast(pid, {:push, data})
  end

  @impl ThousandIsland.Handler
  def handle_data(data, socket, state) do
    {:ok, data} = HAP.HAPSessionTransport.decrypt_if_needed(data)
    Bandit.HTTP1.Handler.handle_data(data, socket, state)
  end

  @impl GenServer
  def handle_cast({:push, data}, {socket, state}) do
    data = Jason.encode!(data)

    headers = %{
      "content-length" => data |> byte_size() |> to_string(),
      "content-type" => "application/hap+json"
    }

    to_send = [
      "EVENT/1.0 200 OK\r\n",
      Enum.map(headers, fn {k, v} -> [k, ": ", v, "\r\n"] end),
      "\r\n",
      data
    ]

    ThousandIsland.Socket.send(socket, to_send)

    {:noreply, {socket, state}}
  end

  def handle_info(msg, state), do: Bandit.HTTP1.Handler.handle_info(msg, state)
end
