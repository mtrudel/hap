defmodule HAP do
  @moduledoc false

  use Supervisor

  def start_link(config) do
    Supervisor.start_link(__MODULE__, config)
  end

  def init(config) do
    config = Application.get_all_env(:hap) |> Keyword.merge(config)

    accessory_server_config = Keyword.get(config, :accessory_server)
    port = Keyword.get(config, :port, 4000)

    children = [
      {HAP.Configuration, accessory_server_config},
      {HAP.AccessoryServer, accessory_server_config},
      HAP.PairSetup,
      {HAP.Discovery, port: port},
      {Bandit, plug: HAP.HTTPServer, options: [transport_module: HAP.HAPSessionTransport, port: port]}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
