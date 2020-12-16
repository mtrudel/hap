defmodule HAP.PersistentStorage do
  @moduledoc false
  # Encapsulates a simple persistent key-value store

  use GenServer

  def start_link(path) do
    GenServer.start_link(__MODULE__, path, name: __MODULE__)
  end

  @doc false
  def get(key, default \\ nil, pid \\ __MODULE__), do: GenServer.call(pid, {:get, key, default})

  @doc false
  def put(key, value, pid \\ __MODULE__), do: GenServer.call(pid, {:put, key, value})

  @doc false
  def put_new_lazy(key, func, pid \\ __MODULE__), do: GenServer.call(pid, {:put_new_lazy, key, func})

  @doc false
  def get_and_update(key, func, pid \\ __MODULE__), do: GenServer.call(pid, {:get_and_update, key, func})

  def init(path) do
    {:ok, cub_pid} = CubDB.start_link(path)

    {:ok, %{cub_pid: cub_pid}}
  end

  def handle_call({:get, key, default}, _from, %{cub_pid: cub_pid} = state) do
    {:reply, CubDB.get(cub_pid, key, default), state}
  end

  def handle_call({:put, key, value}, _from, %{cub_pid: cub_pid} = state) do
    {:reply, CubDB.put(cub_pid, key, value), state}
  end

  def handle_call({:put_new_lazy, key, func}, _from, %{cub_pid: cub_pid} = state) do
    if CubDB.has_key?(cub_pid, key) do
      {:reply, :ok, state}
    else
      {:reply, CubDB.put(cub_pid, key, func.()), state}
    end
  end

  def handle_call({:get_and_update, key, func}, _from, %{cub_pid: cub_pid} = state) do
    {:reply, CubDB.get_and_update(cub_pid, key, func), state}
  end
end
