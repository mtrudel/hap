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

  def paired?(accessory_pid) do
    GenServer.call(accessory_pid, :paired?)
  end

  def accessory_type(accessory_pid) do
    GenServer.call(accessory_pid, :accessory_type)
  end

  def init(config) do
    {:ok, %{config: config, config_number: 1, paired?: false}}
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

  def handle_call(:paired?, _from, state) do
    {:reply, state.paired?, state}
  end

  def handle_call(:accessory_type, _from, state) do
    {:reply, state.config.accessory_type, state}
  end
end
