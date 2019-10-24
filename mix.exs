defmodule HomeKitEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :home_kit_ex,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {HomeKitEx.Application, []}
    ]
  end

  defp deps do
    [
      {:nerves_dnssd, "~> 0.3.1"},
      {:strap, "~> 0.1.1"},
      {:plug_cowboy, "~> 2.0"},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false}
    ]
  end
end
