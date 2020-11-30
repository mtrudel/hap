defmodule HAP.Discovery do
  @moduledoc false
  # Provides functions to define & update a `HAP.Accessory` advertisement via multicast DNS according to Section 6 of
  # Apple's [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/).

  require Logger

  alias HAP.AccessoryServerManager

  @doc false
  def reload do
    Logger.debug("(Re-)Advertising mDNS record")

    <<setup_hash::binary-4, _rest::binary>> =
      :crypto.hash(:sha512, AccessoryServerManager.setup_id() <> AccessoryServerManager.identifier())

    %{
      name: AccessoryServerManager.name(),
      protocol: "hap",
      transport: "tcp",
      port: AccessoryServerManager.port(),
      txt_payload: [
        "c#=#{AccessoryServerManager.config_number()}",
        "ff=0",
        "id=#{AccessoryServerManager.identifier()}",
        "md=#{AccessoryServerManager.model()}",
        "pv=1.1",
        "s#=1",
        "sf=#{if AccessoryServerManager.paired?(), do: 0, else: 1}",
        "ci=#{AccessoryServerManager.accessory_type()}",
        "sh=#{setup_hash |> Base.encode64()}"
      ]
    }
    |> MdnsLite.add_mdns_services()
  end
end
