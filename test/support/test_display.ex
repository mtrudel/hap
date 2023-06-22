defmodule HAP.Test.Display do
  @moduledoc false

  @behaviour HAP.Display

  require Logger

  @impl HAP.Display
  def display_pairing_code(_name, _pairing_code, _pairing_url), do: :ok

  @impl HAP.Display
  def clear_pairing_code, do: :ok

  @impl HAP.Display
  def identify(name) do
    Logger.warning("IDENTIFY #{name}")
  end
end
