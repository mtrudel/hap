defmodule HAP.PersistentStorage do
  @moduledoc """
  Encapsulates a simple persistent key-value store
  """
  use GenServer

  alias HAP.Crypto.EDDSA

  def start_link(path) do
    GenServer.start_link(__MODULE__, path, name: __MODULE__)
  end

  def get(param, pid \\ __MODULE__), do: GenServer.call(pid, {:get, param})
  def put(param, value, pid \\ __MODULE__), do: GenServer.call(pid, {:put, param, value})
  def get_and_update(param, func, pid \\ __MODULE__), do: GenServer.call(pid, {:get_and_update, param, func})

  def init(path) do
    {:ok, cub_pid} = CubDB.start_link(path)

    set_if_missing(cub_pid, :config_number, 0)

    if !CubDB.has_key?(cub_pid, :ltpk) || !CubDB.has_key?(cub_pid, :ltsk) do
      {:ok, ltpk, ltsk} = EDDSA.key_gen()
      CubDB.put(cub_pid, :ltpk, ltpk)
      CubDB.put(cub_pid, :ltsk, ltsk)
    end

    set_if_missing(cub_pid, :pairings, %{})

    {:ok, %{cub_pid: cub_pid}}
  end

  def handle_call({:get, param}, _from, %{cub_pid: cub_pid} = state) do
    {:reply, CubDB.get(cub_pid, param), state}
  end

  def handle_call({:put, param, value}, _from, %{cub_pid: cub_pid} = state) do
    {:reply, CubDB.put(cub_pid, param, value), state}
  end

  def handle_call({:get_and_update, param, func}, _from, %{cub_pid: cub_pid} = state) do
    {:reply, CubDB.get_and_update(cub_pid, param, func), state}
  end

  defp set_if_missing(cub_pid, key, value) do
    if !CubDB.has_key?(cub_pid, key) do
      CubDB.put(cub_pid, key, value)
    end
  end
end
