defmodule HAP.AccessoryServerManager do
  @moduledoc false
  # Holds the top-level state of a HAP accessory server

  use GenServer

  require Logger

  def start_link(config) do
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  @doc false
  def config_number, do: HAP.PersistentStorage.get(:config_number)

  @doc false
  def ltpk, do: HAP.PersistentStorage.get(:ltpk)

  @doc false
  def ltsk, do: HAP.PersistentStorage.get(:ltsk)

  @doc false
  def port(pid \\ __MODULE__), do: GenServer.call(pid, {:get, :port})

  @doc false
  def set_port(port, pid \\ __MODULE__), do: GenServer.call(pid, {:put, :port, port})

  @doc false
  def display_module(pid \\ __MODULE__), do: GenServer.call(pid, {:get, :display_module})

  @doc false
  def name(pid \\ __MODULE__), do: GenServer.call(pid, {:get, :name})

  @doc false
  def model(pid \\ __MODULE__), do: GenServer.call(pid, {:get, :model})

  @doc false
  def identifier(pid \\ __MODULE__), do: GenServer.call(pid, {:get, :identifier})

  @doc false
  def accessory_type(pid \\ __MODULE__), do: GenServer.call(pid, {:get, :accessory_type})

  @doc false
  def pairing_code(pid \\ __MODULE__), do: GenServer.call(pid, {:get, :pairing_code})

  @doc false
  def setup_id(pid \\ __MODULE__), do: GenServer.call(pid, {:get, :setup_id})

  @doc false
  def paired?(pid \\ __MODULE__), do: GenServer.call(pid, :paired?)

  @doc false
  def controller_pairings(pid \\ __MODULE__), do: GenServer.call(pid, :controller_pairings)

  @doc false
  def controller_pairing(ios_identifier, pid \\ __MODULE__) do
    GenServer.call(pid, {:controller_pairing, ios_identifier})
  end

  @doc false
  def add_controller_pairing(ios_identifier, ios_ltpk, permissions, pid \\ __MODULE__) do
    GenServer.call(pid, {:add_controller_pairing, ios_identifier, ios_ltpk, permissions})
  end

  @doc false
  def remove_controller_pairing(ios_identifier, pid \\ __MODULE__) do
    GenServer.call(pid, {:remove_controller_pairing, ios_identifier})
  end

  @doc false
  def get_accessories(pid \\ __MODULE__) do
    GenServer.call(pid, :get_accessories)
  end

  @doc false
  def get_characteristics(characteristics, pid \\ __MODULE__) do
    GenServer.call(pid, {:get_characteristics, characteristics})
  end

  @doc false
  def put_characteristics(characteristics, pid \\ __MODULE__) do
    GenServer.call(pid, {:put_characteristics, characteristics})
  end

  def init(%HAP.AccessoryServer{} = accessory_server) do
    old_config_hash = HAP.PersistentStorage.get(:config_hash)
    new_config_hash = HAP.AccessoryServer.config_hash(accessory_server)

    if old_config_hash != new_config_hash do
      Logger.info("Configuration has changed; incrementing config number")
      HAP.PersistentStorage.get_and_update(:config_number, &{:ok, &1 + 1})
    end

    {:ok, accessory_server}
    HAP.PersistentStorage.put(:config_hash, new_config_hash)
  end

  def handle_call({:get, param}, _from, state) do
    {:reply, Map.get(state, param), state}
  end

  def handle_call({:put, :port, port}, _from, state) do
    {:reply, :ok, Map.put(state, :port, port)}
  end

  def handle_call(:paired?, _from, state) do
    {:reply, HAP.PersistentStorage.get(:pairings) != %{}, state}
  end

  def handle_call(:controller_pairings, _from, state) do
    {:reply, HAP.PersistentStorage.get(:pairings), state}
  end

  def handle_call({:controller_pairing, ios_identifier}, _from, state) do
    {:reply, HAP.PersistentStorage.get(:pairings)[ios_identifier], state}
  end

  def handle_call({:add_controller_pairing, ios_identifier, ios_ltpk, permissions}, _from, state) do
    pairing_state_changed =
      HAP.PersistentStorage.get_and_update(
        :pairings,
        &{&1 == %{}, Map.put(&1, ios_identifier, {ios_ltpk, permissions})}
      )

    {:reply, pairing_state_changed, state}
  end

  def handle_call({:remove_controller_pairing, ios_identifier}, _from, state) do
    pairing_state_changed =
      HAP.PersistentStorage.get_and_update(:pairings, fn pairings ->
        new_map = Map.delete(pairings, ios_identifier)
        {new_map == %{}, new_map}
      end)

    {:reply, pairing_state_changed, state}
  end

  def handle_call(:get_accessories, _from, state) do
    response = HAP.AccessoryServer.accessories_tree(state[:accessory_server])
    {:reply, response, state}
  end

  def handle_call({:get_characteristics, characteristics}, _from, state) do
    response = HAP.AccessoryServer.get_characteristics(state[:accessory_server], characteristics)
    {:reply, response, state}
  end

  def handle_call({:put_characteristics, characteristics}, _from, state) do
    response = HAP.AccessoryServer.put_characteristics(state[:accessory_server], characteristics)
    {:reply, response, state}
  end
end
