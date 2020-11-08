defmodule HAP.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    opts = [strategy: :rest_for_one, name: HAP.Supervisor]
    port = Application.get_env(:hap, :port, 4000)

    children = [
      HAP.AccessoryServer,
      HAP.PairSetup,
      {HAP.Discovery, port: port},
      {Bandit, plug: HAP.HTTPServer, options: [transport_module: HAP.HAPSessionTransport, port: port]}
    ]

    Supervisor.start_link(children, opts)
  end
end
