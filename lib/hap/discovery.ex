defmodule HAP.Discovery do
  @moduledoc false
  # Provides functions to define & update a `HAP.Accessory` advertisement via multicast DNS according to Section 6 of
  # Apple's [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/).

  require Logger

  @doc false
  def reload do
    Logger.debug("(Re-)Advertising mDNS record")

    <<setup_hash::binary-4, _rest::binary>> =
      :crypto.hash(:sha512, HAP.AccessoryServerManager.setup_id() <> HAP.AccessoryServerManager.identifier())

    identifier_atom = HAP.AccessoryServerManager.identifier() |> String.to_atom()

    MdnsLite.remove_mdns_service(identifier_atom)

    %{
      id: identifier_atom,
      instance_name: HAP.AccessoryServerManager.name(),
      protocol: "hap",
      transport: "tcp",
      port: HAP.AccessoryServerManager.port(),
      txt_payload: [
        "c#=#{HAP.AccessoryServerManager.config_number()}",
        "ff=0",
        "id=#{HAP.AccessoryServerManager.identifier()}",
        "md=#{HAP.AccessoryServerManager.model()}",
        "pv=1.1",
        "s#=1",
        "sf=#{if HAP.AccessoryServerManager.paired?(), do: 0, else: 1}",
        "ci=#{HAP.AccessoryServerManager.accessory_type()}",
        "sh=#{setup_hash |> Base.encode64()}"
      ]
    }
    |> MdnsLite.add_mdns_service()
  end
end
