defmodule HAP.MixProject do
  use Mix.Project

  def project do
    [
      app: :hap,
      version: "0.1.1",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      dialyzer: dialyzer(),
      name: "HAP",
      description: "An implementation of the HomeKit Accessory Protocol",
      source_url: "https://github.com/mtrudel/hap",
      package: [
        files: ["lib", "test", "mix.exs", "README*", "LICENSE*", ".credo.exs", ".formatter.exs"],
        maintainers: ["Mat Trudel"],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/mtrudel/hap"}
      ],
      docs: docs()
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
      {:cubdb, "~> 0.17.0"},
      {:eqrcode, "~> 0.1.7"},
      {:hkdf, "~> 0.1.0"},
      {:jason, "~> 1.2"},
      {:mdns_lite, "~> 0.6"},
      {:strap, "~> 0.1.1"},
      {:temp, "~> 0.4", only: :test},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false},
      {:ex_doc, "~> 0.21", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp dialyzer do
    [plt_core_path: "priv/plts", plt_file: {:no_warn, "priv/plts/dialyzer.plt"}]
  end

  defp docs do
    [
      main: "HAP",
      groups_for_modules: [
        # HAP,
        # HAP.Accessory,
        # HAP.AccessoryServer,
        Behaviours: [
          HAP.Display,
          HAP.ValueStore
        ],
        Services: [
          HAP.Service,
          HAP.Services.AccessoryInformation,
          HAP.Services.LightBulb,
          HAP.Services.ProtocolInformation
        ],
        Characteristics: [
          HAP.Characteristic,
          HAP.Characteristics.FirmwareRevision,
          HAP.Characteristics.Identify,
          HAP.Characteristics.Manufacturer,
          HAP.Characteristics.Model,
          HAP.Characteristics.Name,
          HAP.Characteristics.On,
          HAP.Characteristics.SerialNumber,
          HAP.Characteristics.Version
        ]
      ]
    ]
  end
end
