defmodule HAP do
  @moduledoc false

  use Supervisor

  def start_link(config) do
    Supervisor.start_link(__MODULE__, config)
  end

  def build_accessory_server(accessory_server) do
    HAP.AccessoryServer.build_accessory_server(accessory_server)
  end

  def build_accessory(accessory) do
    HAP.Accessory.build_accessory(accessory)
  end

  def init(%HAP.AccessoryServer{} = config) do
    children = [
      HAP.PersistentStorage,
      {HAP.AccessoryServerManager, config},
      HAP.PairSetup,
      {HAP.Discovery, port: config.port},
      {Bandit, plug: HAP.HTTPServer, options: [transport_module: HAP.HAPSessionTransport, port: config.port]}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
