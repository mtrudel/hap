defmodule HAP.Test.TestValueStore do
  @moduledoc """
  A simple GenServer backed value store for testing
  """

  @behaviour HAP.ValueStore

  use GenServer

  def start_link(config) do
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  @impl HAP.ValueStore
  def get_value(opts) do
    GenServer.call(__MODULE__, {:get, opts})
  end

  @impl HAP.ValueStore
  def put_value(value, opts) do
    GenServer.call(__MODULE__, {:put, value, opts})
  end

  @impl GenServer
  def init(_) do
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:get, opts}, _from, state) do
    {:reply, Map.get(state, Keyword.get(opts, :value_name), 0), state}
  end

  @impl GenServer
  def handle_call({:put, value, opts}, _from, state) do
    {:reply, :ok, Map.put(state, Keyword.get(opts, :value_name), value)}
  end
end
