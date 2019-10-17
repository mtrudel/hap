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

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {HomeKitEx.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nerves_dnssd, "~> 0.3.1"},
      {:srp, "~> 0.2.0"},
      {:plug_cowboy, "~> 2.0"}
    ]
  end
end
