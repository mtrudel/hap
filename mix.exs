defmodule HAP.MixProject do
  use Mix.Project

  def project do
    [
      app: :hap,
      version: "0.4.1",
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
      {:bandit, "~> 0.2.0"},
      {:base36, "~> 1.0"},
      {:cubdb, "~> 0.17.0"},
      {:eqrcode, "~> 0.1.7"},
      {:hkdf, "~> 0.1.0"},
      {:jason, "~> 1.2"},
      {:mdns_lite, "~> 0.6"},
      {:strap, "~> 0.1.1"},
      {:temp, "~> 0.4", only: :test},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.21", only: [:dev, :test], runtime: false}
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
        Behaviours: [
          HAP.Display,
          HAP.ValueStore
        ],
        Services: [
          HAP.Service,
          HAP.ServiceSource,
          HAP.Services.AccessoryInformation,
          HAP.Services.ContactSensor,
          HAP.Services.HeaterCooler,
          HAP.Services.LeakSensor,
          HAP.Services.LightBulb,
          HAP.Services.LightSensor,
          HAP.Services.MotionSensor,
          HAP.Services.OccupancySensor,
          HAP.Services.Outlet,
          HAP.Services.ProtocolInformation,
          HAP.Services.Switch,
          HAP.Services.TemperatureSensor,
          HAP.Services.Window,
          HAP.Services.WindowCovering
        ],
        Characteristics: [
          HAP.Characteristic,
          HAP.CharacteristicDefinition,
          HAP.Characteristics.Active,
          HAP.Characteristics.Brightness,
          HAP.Characteristics.ColorTemperature,
          HAP.Characteristics.ContactSensorState,
          HAP.Characteristics.CoolingThresholdTemperature,
          HAP.Characteristics.CurrentAmbientLightLevel,
          HAP.Characteristics.CurrentHeaterCoolerState,
          HAP.Characteristics.CurrentHorizontalTiltAngle,
          HAP.Characteristics.CurrentPosition,
          HAP.Characteristics.CurrentTemperature,
          HAP.Characteristics.CurrentVerticalTiltAngle,
          HAP.Characteristics.FirmwareRevision,
          HAP.Characteristics.HeatingThresholdTemperature,
          HAP.Characteristics.HoldPosition,
          HAP.Characteristics.Hue,
          HAP.Characteristics.Identify,
          HAP.Characteristics.LeakDetected,
          HAP.Characteristics.LockPhysicalControls,
          HAP.Characteristics.Manufacturer,
          HAP.Characteristics.Model,
          HAP.Characteristics.MotionDetected,
          HAP.Characteristics.Name,
          HAP.Characteristics.ObstructionDetected,
          HAP.Characteristics.OccupancyDetected,
          HAP.Characteristics.On,
          HAP.Characteristics.OutletInUse,
          HAP.Characteristics.PositionState,
          HAP.Characteristics.RotationSpeed,
          HAP.Characteristics.Saturation,
          HAP.Characteristics.SerialNumber,
          HAP.Characteristics.StatusActive,
          HAP.Characteristics.StatusFault,
          HAP.Characteristics.StatusLowBattery,
          HAP.Characteristics.StatusTampered,
          HAP.Characteristics.SwingMode,
          HAP.Characteristics.TargetHeaterCoolerState,
          HAP.Characteristics.TargetHorizontalTiltAngle,
          HAP.Characteristics.TargetPosition,
          HAP.Characteristics.TargetVerticalTiltAngle,
          HAP.Characteristics.TemperatureDisplayUnits,
          HAP.Characteristics.Version
        ]
      ]
    ]
  end
end
