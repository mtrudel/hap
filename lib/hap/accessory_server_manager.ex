defmodule HAP.AccessoryServerManager do
  @moduledoc """
  Holds the top-level state of a HAP accessory server
  """

  use GenServer

  require Logger

  alias HAP.PersistentStorage

  def start_link(config) do
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  # Note that these functions actually call through to PersistentStorage
  def config_number, do: PersistentStorage.get(:config_number)
  def ltpk, do: PersistentStorage.get(:ltpk)
  def ltsk, do: PersistentStorage.get(:ltsk)
  def name(pid \\ __MODULE__), do: GenServer.call(pid, {:get, :name})
  def model(pid \\ __MODULE__), do: GenServer.call(pid, {:get, :model})
  def identifier(pid \\ __MODULE__), do: GenServer.call(pid, {:get, :identifier})
  def accessory_type(pid \\ __MODULE__), do: GenServer.call(pid, {:get, :accessory_type})
  def pairing_code(pid \\ __MODULE__), do: GenServer.call(pid, {:get, :pairing_code})
  def setup_id(pid \\ __MODULE__), do: GenServer.call(pid, {:get, :setup_id})
  def paired?(pid \\ __MODULE__), do: GenServer.call(pid, :paired?)
  def controller_pairings(pid \\ __MODULE__), do: GenServer.call(pid, :controller_pairings)

  def controller_pairing(ios_identifier, pid \\ __MODULE__) do
    GenServer.call(pid, {:controller_pairing, ios_identifier})
  end

  def add_controller_pairing(ios_identifier, ios_ltpk, permissions, pid \\ __MODULE__) do
    GenServer.call(pid, {:add_controller_pairing, ios_identifier, ios_ltpk, permissions})
  end

  def remove_controller_pairing(ios_identifier, pid \\ __MODULE__) do
    GenServer.call(pid, {:remove_controller_pairing, ios_identifier})
  end

  def get_accessories(pid \\ __MODULE__) do
    GenServer.call(pid, :get_accessories)
  end

  def get_characteristics(characteristics, pid \\ __MODULE__) do
    GenServer.call(pid, {:get_characteristics, characteristics})
  end

  def put_characteristics(characteristics, pid \\ __MODULE__) do
    GenServer.call(pid, {:put_characteristics, characteristics})
  end

  def init(%HAP.AccessoryServer{} = accessory_server) do
    old_config_hash = PersistentStorage.get(:config_hash)
    new_config_hash = HAP.AccessoryServer.config_hash(accessory_server)

    if old_config_hash != new_config_hash do
      Logger.info("Configuration has changed; incrementing config number")
      PersistentStorage.get_and_update(:config_number, &{:ok, &1 + 1})
    end

    PersistentStorage.put(:config_hash, new_config_hash)
    {:ok, accessory_server}
  end

  def handle_call({:get, param}, _from, state) do
    {:reply, Map.get(state, param), state}
  end

  def handle_call(:paired?, _from, state) do
    {:reply, PersistentStorage.get(:pairings) != %{}, state}
  end

  def handle_call(:controller_pairings, _from, state) do
    {:reply, PersistentStorage.get(:pairings), state}
  end

  def handle_call({:controller_pairing, ios_identifier}, _from, state) do
    {:reply, PersistentStorage.get(:pairings)[ios_identifier], state}
  end

  def handle_call({:add_controller_pairing, ios_identifier, ios_ltpk, permissions}, _from, state) do
    pairing_state_changed =
      PersistentStorage.get_and_update(:pairings, &{&1 == %{}, Map.put(&1, ios_identifier, {ios_ltpk, permissions})})

    {:reply, pairing_state_changed, state}
  end

  def handle_call({:remove_controller_pairing, ios_identifier}, _from, state) do
    pairing_state_changed =
      PersistentStorage.get_and_update(:pairings, fn pairings ->
        new_map = Map.delete(pairings, ios_identifier)
        {new_map == %{}, new_map}
      end)

    {:reply, pairing_state_changed, state}
  end

  def handle_call(:get_accessories, _from, state) do
    response = HAP.AccessoryServer.accessories_tree(state)
    {:reply, response, state}
  end

  def handle_call({:get_characteristics, characteristics}, _from, state) do
    response = HAP.AccessoryServer.get_characteristics(state, characteristics)
    {:reply, response, state}
  end

  def handle_call({:put_characteristics, characteristics}, _from, state) do
    response = HAP.AccessoryServer.put_characteristics(state, characteristics)
    {:reply, response, state}
  end
end
