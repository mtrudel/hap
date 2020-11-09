defmodule HAP.AccessoryServer do
  @moduledoc """
  Manages a collection of accessory object instances
  """

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    {:ok, %{}, {:continue, :display_startup_info}}
  end

  def handle_continue(:display_startup_info, state) do
    HAP.Display.display_startup_info()
    {:noreply, state}
  end
end
