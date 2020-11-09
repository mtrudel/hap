defmodule HAP.AccessoryServer do
  @moduledoc """
  Manages a collection of accessory object instances
  """

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    {:ok, %{}}
  end
end
