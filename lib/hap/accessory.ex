defmodule HAP.Accessory do
  @moduledoc """
  Manages high-level concerns of a HomeKit Accessory construct, including
  aspects of message handling and pairing state tracking. This module is the 
  principal holder of state within the `HAP` application
  """

  use GenServer

  def start_link(config) do
    GenServer.start_link(__MODULE__, config)
  end

  @doc """
  Returns the information required to advertise this accessory via mDNS
  """
  def discovery_state(accessory_pid) do
    GenServer.call(accessory_pid, :discovery_state)
  end

  @doc """
  Returns the pairing state of this accessory
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
    # TODO Read pairing state from persistent storage if it exists
    # TODO Read setup code from persistent storage if it exists
    pairing_state = HAP.PairingStates.Unpaired.new()
    setup_id = random_setup_id()

    {:ok, %{config: config, pairing_state: pairing_state, setup_id: setup_id}, {:continue, :display_pairing_code}}
  end

  def handle_call(:discovery_state, _from, state) do
    discovery_state = %{
      config_number: 1,
      identifier: state.config.identifier,
      name: state.config.name,
      accessory_type: state.config.accessory_type,
      setup_id: state.setup_id,
      paired: match?(%HAP.PairingStates.Paired{}, state.pairing_state)
    }

    {:reply, discovery_state, state}
  end

  def handle_call(:pairing_state, _from, state) do
    {:reply, state.pairing_state, state}
  end

  def handle_call({:set_pairing_state, pairing_state}, _from, state) do
    {:reply, :ok, %{state | pairing_state: pairing_state}}
  end

  def handle_continue(
        :display_pairing_code,
        %{pairing_state: %HAP.PairingStates.Unpaired{pairing_code: pairing_code}} = state
      ) do
    HAP.Display.display_pairing_code(state.config.accessory_type, pairing_code, state.setup_id)
    {:noreply, state}
  end

  def handle_continue(:display_pairing_code, state), do: {:noreply, state}

  def random_setup_id do
    Stream.repeatedly(fn -> <<Enum.random(?A..?Z)>> end) |> Enum.take(4) |> Enum.join()
  end
end
