defmodule HomeKitEx.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    opts = [strategy: :rest_for_one, name: HomeKitEx.Supervisor]
    {:ok, sup} = Supervisor.start_link([], opts)

    accessory_spec = {HomeKitEx.Accessory, Application.get_env(:home_kit_ex, :accessory)}
    {:ok, accessory_pid} = Supervisor.start_child(sup, accessory_spec)

    port = Application.get_env(:home_kit_ex, :port)

    dns_sd_spec = {HomeKitEx.Discovery, accessory: accessory_pid, port: port}
    Supervisor.start_child(sup, dns_sd_spec)

    plug_spec = {Plug.Cowboy, scheme: :http, plug: {HomeKitEx.Plug, accessory_pid}, options: [port: port]}
    Supervisor.start_child(sup, plug_spec)

    {:ok, sup}
  end
end
