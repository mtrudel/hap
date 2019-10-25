defmodule HAP.Discovery do
  @moduledoc """
  Defines a process that advertises a `HAP.Accessory` via multicast DNS
  according to Section 6 of Apple's [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/). 
  """

  alias HAP.Accessory

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
    accessory_pid = Keyword.get(opts, :accessory)
    config_number = Accessory.config_number(accessory_pid)
    identifier = Accessory.identifier(accessory_pid)
    name = Accessory.name(accessory_pid)
    status_flag = if Accessory.paired?(accessory_pid), do: "0", else: "1"
    accessory_type = Accessory.accessory_type(accessory_pid)
    setup_id = Accessory.setup_id(accessory_pid)
    <<setup_hash::binary-size(4), _rest::binary>> = :crypto.hash(:sha512, setup_id <> identifier)
    setup_hash = Base.encode64(setup_hash)

    txts = [
      "c#": to_string(config_number),
      ff: "0",
      pv: "1.0",
      id: to_string(identifier),
      md: name,
      "s#": "1",
      sf: status_flag,
      ci: to_string(accessory_type),
      sh: setup_hash
    ]

    Nerves.Dnssd.register(name, "_hap._tcp", Keyword.get(opts, :port), txts)
  end
end
