defmodule HomeKitEx.Discovery do
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
    config_number = HomeKitEx.Accessory.config_number(accessory_pid)
    identifier = HomeKitEx.Accessory.identifier(accessory_pid)
    name = HomeKitEx.Accessory.name(accessory_pid)
    status_flag = if HomeKitEx.Accessory.paired?(accessory_pid), do: "0", else: "1"
    accessory_type = HomeKitEx.Accessory.accessory_type(accessory_pid)

    txts = [
      "c#": to_string(config_number),
      ff: "1",
      id: to_string(identifier),
      md: name,
      "s#": "1",
      sf: status_flag,
      ci: to_string(accessory_type)
    ]

    Nerves.Dnssd.register(name, "_hap._tcp", Keyword.get(opts, :port), txts)
  end
end
