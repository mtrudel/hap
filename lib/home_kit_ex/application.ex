defmodule HomeKitEx.Application do
  @moduledoc false

  use Application

  @name "MatDevice"
  @port 4000

  def start(_type, _args) do
    children = [
      {HomeKitEx.Discovery, name: @name, port: @port},
      {Plug.Cowboy, scheme: :http, plug: HomeKitEx.Plug, options: [port: @port]}
    ]

    opts = [strategy: :one_for_one, name: HomeKitEx.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
