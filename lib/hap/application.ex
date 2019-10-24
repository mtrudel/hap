defmodule HAP.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    opts = [strategy: :rest_for_one, name: HAP.Supervisor]
    {:ok, sup} = Supervisor.start_link([], opts)

    accessory_spec = {HAP.Accessory, Application.get_env(:hap, :accessory)}
    {:ok, accessory_pid} = Supervisor.start_child(sup, accessory_spec)

    port = Application.get_env(:hap, :port)

    dns_sd_spec = {HAP.Discovery, accessory: accessory_pid, port: port}
    Supervisor.start_child(sup, dns_sd_spec)

    plug_spec = {Plug.Cowboy, scheme: :http, plug: {HAP.HTTPServer, accessory: accessory_pid}, options: [port: port]}

    Supervisor.start_child(sup, plug_spec)

    {:ok, sup}
  end
end
