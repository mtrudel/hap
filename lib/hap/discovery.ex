defmodule HAP.Discovery do
  @moduledoc """
  Defines a process that advertises a `HAP.Accessory` via multicast DNS
  according to Section 6 of Apple's [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/). 
  """

  # TODO this will need to become a full blown GenServer in order to receive 
  # updates about an Accessory's pairing state
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(opts) do
    discovery_state =
      opts
      |> Keyword.get(:accessory)
      |> HAP.Accessory.discovery_state()

    status_flag = if discovery_state.paired, do: "0", else: "1"

    <<setup_hash::binary-size(4), _rest::binary>> =
      :crypto.hash(:sha512, discovery_state.setup_id <> discovery_state.identifier)

    setup_hash = Base.encode64(setup_hash)

    txts = [
      "c#": to_string(discovery_state.config_number),
      ff: "0",
      pv: "1.0",
      id: discovery_state.identifier,
      md: discovery_state.name,
      "s#": "1",
      sf: status_flag,
      ci: to_string(discovery_state.accessory_type),
      sh: setup_hash
    ]

    Nerves.Dnssd.register(discovery_state.name, "_hap._tcp", Keyword.get(opts, :port), txts)
  end
end
