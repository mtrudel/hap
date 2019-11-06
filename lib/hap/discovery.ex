defmodule HAP.Discovery do
  @moduledoc """
  Defines a process that advertises a `HAP.Accessory` via multicast DNS
  according to Section 6 of Apple's [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/). 
  """

  use GenServer

  alias HAP.Accessory

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def reload(pid \\ __MODULE__) do
    GenServer.cast(pid, :reload)
  end

  def init(opts) do
    {:ok, pid} = start_dnssd_daemon(opts)
    {:ok, %{pid: pid, opts: opts}}
  end

  def handle_cast(:reload, %{pid: pid, opts: opts} = state) do
    Supervisor.stop(pid)
    {:ok, pid} = start_dnssd_daemon(opts)
    {:noreply, %{state | pid: pid}}
  end

  defp start_dnssd_daemon(opts) do
    status_flag = if Accessory.paired?(), do: "0", else: "1"

    <<setup_hash::binary-4, _rest::binary>> = :crypto.hash(:sha512, Accessory.setup_id() <> Accessory.identifier())

    txts = [
      "c#": Accessory.config_number() |> to_string(),
      ff: "0",
      id: Accessory.identifier(),
      md: Accessory.name(),
      "s#": "1",
      sf: status_flag,
      ci: Accessory.accessory_type() |> to_string(),
      sh: setup_hash |> Base.encode64()
    ]

    Nerves.Dnssd.register(Accessory.name(), "_hap._tcp", Keyword.get(opts, :port), txts)
  end
end
