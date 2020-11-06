defmodule HAP.Accessory do
  @moduledoc """
  Manages accessory-level state, including device information, pairings, and setup info
  """

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def config_number(pid \\ __MODULE__), do: GenServer.call(pid, :config_number)
  def name(pid \\ __MODULE__), do: GenServer.call(pid, :name)
  def identifier(pid \\ __MODULE__), do: GenServer.call(pid, :identifier)
  def pairing_code(pid \\ __MODULE__), do: GenServer.call(pid, :pairing_code)
  def accessory_type(pid \\ __MODULE__), do: GenServer.call(pid, :accessory_type)
  def setup_id(pid \\ __MODULE__), do: GenServer.call(pid, :setup_id)
  def ltpk(pid \\ __MODULE__), do: GenServer.call(pid, :ltpk)
  def ltsk(pid \\ __MODULE__), do: GenServer.call(pid, :ltsk)
  def paired?(pid \\ __MODULE__), do: GenServer.call(pid, :paired?)

  def get_controller_pairing(ios_identifier, pid \\ __MODULE__) do
    GenServer.call(pid, {:get_controller_pairing, ios_identifier})
  end

  def add_controller_pairing(ios_identifier, ios_ltpk, pid \\ __MODULE__) do
    GenServer.call(pid, {:add_controller_pairing, ios_identifier, ios_ltpk})
  end

  def init(_opts) do
    config = HAP.Configuration.config()
    {:ok, %{config: config, pairings: %{}}, {:continue, :display_startup_info}}
  end

  def handle_continue(:display_startup_info, state) do
    HAP.Display.display_startup_info(state.config, !Enum.empty?(state.pairings))
    {:noreply, state}
  end

  def handle_call(:config_number, _from, state), do: {:reply, 1, state}
  def handle_call(:name, _from, state), do: {:reply, state.config.name, state}
  def handle_call(:identifier, _from, state), do: {:reply, state.config.identifier, state}
  def handle_call(:pairing_code, _from, state), do: {:reply, state.config.pairing_code, state}
  def handle_call(:accessory_type, _from, state), do: {:reply, state.config.accessory_type, state}
  def handle_call(:setup_id, _from, state), do: {:reply, state.config.setup_id, state}
  def handle_call(:ltpk, _from, state), do: {:reply, state.config.ltpk, state}
  def handle_call(:ltsk, _from, state), do: {:reply, state.config.ltsk, state}
  def handle_call(:paired?, _from, state), do: {:reply, !Enum.empty?(state.pairings), state}

  def handle_call({:get_controller_pairing, ios_identifier}, _from, state) do
    {:reply, state.pairings[ios_identifier], state}
  end

  def handle_call({:add_controller_pairing, ios_identifier, ios_ltpk}, _from, state) do
    HAP.Display.display_new_pairing_info(ios_identifier)
    if state.pairings == %{}, do: HAP.Discovery.reload()
    state = state |> Map.update!(:pairings, &Map.put(&1, ios_identifier, ios_ltpk))
    {:reply, :ok, state}
  end
end
