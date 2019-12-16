defmodule HAP.MixProject do
  use Mix.Project

  def project do
    [
      app: :hap,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {HAP.Application, []}
    ]
  end

  defp deps do
    [
      {:nerves_dnssd, "~> 0.3.1"},
      {:strap, "~> 0.1.1"},
      {:plug_cowboy, "~> 2.0"},
      {:eqrcode, "~> 0.1.7"},
      {:base36, "~> 1.0"},
      {:hkdf, "~> 0.1.0"},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false}
    ]
  end
end
