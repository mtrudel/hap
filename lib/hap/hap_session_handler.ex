defmodule HAP.HAPSessionHandler do
  @moduledoc false
  # HAP requires a number of low-level changes to HTTP, which are provided by a mix 
  # of this module and a specialized Thousand Island transport module

  use ThousandIsland.Handler

  @doc false
  # Push an asynchronous message to the client as described in section 6.8 of the 
  # HomeKit Accessory Protocol specification
  def push(pid, data) do
    GenServer.cast(pid, {:push, data})
  end

  @impl ThousandIsland.Handler
  def handle_data(data, socket, plug) do
    # TODO - we should be holding encryption state in state and not in 
    # the process dictionary
    {:ok, data} = HAP.HAPSessionTransport.decrypt_if_needed(data)
    {:ok, adapter_mod, req} = Bandit.HTTP1Request.request(socket, data)

    try do
      case Bandit.ConnPipeline.run(adapter_mod, req, plug) do
        {:ok, req} ->
          if adapter_mod.keepalive?(req) do
            {:ok, :continue, plug}
          else
            {:ok, :close, plug}
          end

        {:error, code, reason} ->
          adapter_mod.send_fallback_resp(req, code)
          {:error, reason, plug}
      end
    rescue
      exception ->
        adapter_mod.send_fallback_resp(req, 500)
        {:error, exception, plug}
    end
  end

  @impl GenServer
  def handle_cast({:push, data}, {socket, state}) do
    data = Jason.encode!(data)

    headers = %{
      "content-length" => data |> byte_size() |> to_string(),
      "content-type" => "application/hap+json"
    }

    to_send = ["EVENT/1.0 200 OK\r\n", Enum.map(headers, fn {k, v} -> [k, ": ", v, "\r\n"] end), "\r\n", data]
    ThousandIsland.Socket.send(socket, to_send)

    {:noreply, {socket, state}}
  end

  def handle_info({:plug_conn, :sent}, state), do: {:noreply, state}
end
