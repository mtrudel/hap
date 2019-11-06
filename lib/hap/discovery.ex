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
