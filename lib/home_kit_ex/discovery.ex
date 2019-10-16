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
    txts = [
      "c#": "1",
      ff: "1",
      id: "00:11:22:33:44:55",
      md: Keyword.get(opts, :name),
      "s#": "1",
      sf: "1",
      ci: "12"
    ]

    Nerves.Dnssd.register(Keyword.get(opts, :name), "_hap._tcp", Keyword.get(opts, :port), txts)
  end
end
