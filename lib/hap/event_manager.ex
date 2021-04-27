defmodule HAP.EventManager do
  @moduledoc false

  use GenServer

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def register(sender, aid, iid) do
    GenServer.call(__MODULE__, {:register, sender, aid, iid})
  end

  def unregister(sender, aid, iid) do
    GenServer.call(__MODULE__, {:unregister, sender, aid, iid})
  end

  def get_listeners(aid, iid) do
    GenServer.call(__MODULE__, {:get_listeners, aid, iid})
  end

  def init(_arg) do
    {:ok, %{}}
  end

  def handle_call({:register, sender, aid, iid}, _from, state) do
    {:reply, {:ok, {aid, iid}}, state |> Map.update({aid, iid}, [sender], fn existing -> [sender | existing] end)}
  end

  def handle_call({:unregister, sender, aid, iid}, _from, state) do
    {:reply, :ok, state |> Map.update({aid, iid}, [], fn existing -> existing |> List.delete(sender) end)}
  end

  def handle_call({:get_listeners, aid, iid}, _from, state) do
    {:reply, state |> Map.get({aid, iid}, []), state}
  end
end
