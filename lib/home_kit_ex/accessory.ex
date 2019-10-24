defmodule HomeKitEx.Accessory do
  @moduledoc """
  Manages high-level concerns of a HomeKit Accessory construct, including
  aspects of message handling and pairing state tracking. This module is the 
  principal holder of state within the `HomeKitEx` application
  """

  use GenServer

  def start_link(config) do
    GenServer.start_link(__MODULE__, config)
  end

  @doc """
  The configuration number. Per the HomeKit spec, this should increment by one
  whenever "an accessory, service, or characteristic is added or removed on the accessory server",
  as well as after a firmware update. 

  In actuality, this returns `1` in all cases
  """
  def config_number(accessory_pid) do
    GenServer.call(accessory_pid, :config_number)
  end

  @doc """
  The identifier of this accessory as described in config
  """
  def identifier(accessory_pid) do
    GenServer.call(accessory_pid, :identifier)
  end

  @doc """
  The name of this accessory as described in config
  """
  def name(accessory_pid) do
    GenServer.call(accessory_pid, :name)
  end

  @doc """
  The accessory type of this accessory as described in config
  """
  def accessory_type(accessory_pid) do
    GenServer.call(accessory_pid, :accessory_type)
  end

  @doc """
  Returns whether or not this accessory is paired
  """
  def paired?(accessory_pid) do
    GenServer.call(accessory_pid, :paired?)
  end

  @doc """
  Returns the specific pairing state of this accessory
  """
  def pairing_state(accessory_pid) do
    GenServer.call(accessory_pid, :pairing_state)
  end

  @doc """
  Sets the pairing state of this accessory
  """
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
