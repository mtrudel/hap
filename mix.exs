defmodule HAP.MixProject do
  use Mix.Project

  def project do
    [
      app: :hap,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto, :ssl]
    ]
  end

  defp deps do
    [
      {:bandit, "~> 0.1.1"},
      {:base36, "~> 1.0"},
      {:cubdb, "~> 1.0.0-rc.5"},
      {:eqrcode, "~> 0.1.7"},
      {:hkdf, "~> 0.1.0"},
      {:jason, "~> 1.2"},
      {:mdns_lite, "~> 0.6"},
      {:strap, "~> 0.1.1"},
      {:httpoison, "~> 1.7", only: :test},
      {:temp, "~> 0.4", only: :test},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
