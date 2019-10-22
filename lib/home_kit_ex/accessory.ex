defmodule HomeKitEx.Accessory do
  use GenServer

  def start_link(config) do
    GenServer.start_link(__MODULE__, config)
  end

  def config_number(accessory_pid) do
    GenServer.call(accessory_pid, :config_number)
  end

  def identifier(accessory_pid) do
    GenServer.call(accessory_pid, :identifier)
  end

  def name(accessory_pid) do
    GenServer.call(accessory_pid, :name)
  end

  def accessory_type(accessory_pid) do
    GenServer.call(accessory_pid, :accessory_type)
  end

  def paired?(accessory_pid) do
    GenServer.call(accessory_pid, :paired?)
  end

  def pairing_state(accessory_pid) do
    GenServer.call(accessory_pid, :pairing_state)
  end

  def set_pairing_state(accessory_pid, pairing_state) do
    GenServer.call(accessory_pid, {:set_pairing_state, pairing_state})
  end

  def init(config) do
    {:ok, %{config: config, config_number: 1, pairing_state: nil}}
  end

  def handle_call(:config_number, _from, state) do
    {:reply, state.config_number, state}
  end

  def handle_call(:identifier, _from, state) do
    {:reply, state.config.identifier, state}
  end

  def handle_call(:name, _from, state) do
    {:reply, state.config.name, state}
  end

  def handle_call(:accessory_type, _from, state) do
    {:reply, state.config.accessory_type, state}
  end

  def handle_call(:paired?, _from, state) do
    {:reply, false, state}
  end

  def handle_call(:pairing_state, _from, state) do
    {:reply, state.pairing_state, state}
  end

  def handle_call({:set_pairing_state, pairing_state}, _from, state) do
    {:reply, :ok, %{state | pairing_state: pairing_state}}
  end
end
