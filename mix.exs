defmodule HAP.MixProject do
  use Mix.Project

  def project do
    [
      app: :hap,
      version: "0.6.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
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
      {:bandit, "~> 1.0"},
      {:base36, "~> 1.0"},
      {:cubdb, "~> 2.0.0"},
      {:eqrcode, "~> 0.2.0"},
      {:hkdf, "~> 0.3.0"},
      {:jason, "~> 1.2"},
      {:mdns_lite, "~> 0.8.3"},
      {:strap, "~> 0.1.1"},
      {:kino, "~> 0.7", optional: true},
      {:temp, "~> 0.4", only: :test},
      {:mix_test_watch, "~> 1.1", only: :dev, runtime: false},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.21", only: [:dev, :test], runtime: false}
    ]
  end

  defp dialyzer do
    [
      plt_core_path: "priv/plts",
      plt_add_apps: [:kino],
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end

  defp docs do
    [
      main: "HAP",
      nest_modules_by_prefix: [HAP.Services, HAP.Characteristics],
      groups_for_modules: [
        Behaviours: [
          HAP.Display,
          HAP.ValueStore
        ],
        Services: [
          HAP.Service,
          HAP.ServiceSource,
          HAP.Services.AccessoryInformation,
          HAP.Services.AirPurifier,
          HAP.Services.AirQualitySensor,
          HAP.Services.CarbonDioxideSensor,
          HAP.Services.CarbonMonoxideSensor,
          HAP.Services.ContactSensor,
          HAP.Services.Door,
          HAP.Services.DoorBell,
          HAP.Services.FanV2,
          HAP.Services.Faucet,
          HAP.Services.GarageDoor,
          HAP.Services.HeaterCooler,
          HAP.Services.HumiditySensor,
          HAP.Services.LeakSensor,
          HAP.Services.LightBulb,
          HAP.Services.LightSensor,
          HAP.Services.Microphone,
          HAP.Services.MotionSensor,
          HAP.Services.OccupancySensor,
          HAP.Services.Outlet,
          HAP.Services.ProtocolInformation,
          HAP.Services.SmokeSensor,
          HAP.Services.ServiceLabel,
          HAP.Services.Slat,
          HAP.Services.Speaker,
          HAP.Services.StatelessProgrammableSwitch,
          HAP.Services.Switch,
          HAP.Services.TemperatureSensor,
          HAP.Services.Thermostat,
          HAP.Services.Window,
          HAP.Services.WindowCovering
        ],
        Characteristics: [
          HAP.Characteristic,
          HAP.CharacteristicDefinition,
          HAP.Characteristics.Active,
          HAP.Characteristics.AirQuality,
          HAP.Characteristics.Brightness,
          HAP.Characteristics.CarbonDioxideDetected,
          HAP.Characteristics.CarbonDioxideLevel,
          HAP.Characteristics.CarbonDioxidePeakLevel,
          HAP.Characteristics.CarbonMonoxideDetected,
          HAP.Characteristics.CarbonMonoxideLevel,
          HAP.Characteristics.CarbonMonoxidePeakLevel,
          HAP.Characteristics.ColorTemperature,
          HAP.Characteristics.ContactSensorState,
          HAP.Characteristics.CoolingThresholdTemperature,
          HAP.Characteristics.CurrentAirPurifierState,
          HAP.Characteristics.CurrentAmbientLightLevel,
          HAP.Characteristics.CurrentDoorState,
          HAP.Characteristics.CurrentFanState,
          HAP.Characteristics.CurrentHeaterCoolerState,
          HAP.Characteristics.CurrentHeatingCoolingState,
          HAP.Characteristics.CurrentHorizontalTiltAngle,
          HAP.Characteristics.CurrentPosition,
          HAP.Characteristics.CurrentRelativeHumidity,
          HAP.Characteristics.CurrentSlatState,
          HAP.Characteristics.CurrentTemperature,
          HAP.Characteristics.CurrentTiltAngle,
          HAP.Characteristics.CurrentVerticalTiltAngle,
          HAP.Characteristics.FirmwareRevision,
          HAP.Characteristics.HeatingThresholdTemperature,
          HAP.Characteristics.HoldPosition,
          HAP.Characteristics.Hue,
          HAP.Characteristics.Identify,
          HAP.Characteristics.InputEvent,
          HAP.Characteristics.LeakDetected,
          HAP.Characteristics.LockCurrentState,
          HAP.Characteristics.LockTargetState,
          HAP.Characteristics.LockPhysicalControls,
          HAP.Characteristics.Manufacturer,
          HAP.Characteristics.Model,
          HAP.Characteristics.MotionDetected,
          HAP.Characteristics.Mute,
          HAP.Characteristics.Name,
          HAP.Characteristics.NitrogenDioxideDensity,
          HAP.Characteristics.ObstructionDetected,
          HAP.Characteristics.OccupancyDetected,
          HAP.Characteristics.On,
          HAP.Characteristics.OutletInUse,
          HAP.Characteristics.OzoneDensity,
          HAP.Characteristics.PM10Density,
          HAP.Characteristics.PM25Density,
          HAP.Characteristics.PositionState,
          HAP.Characteristics.RotationDirection,
          HAP.Characteristics.RotationSpeed,
          HAP.Characteristics.Saturation,
          HAP.Characteristics.SerialNumber,
          HAP.Characteristics.SmokeDetected,
          HAP.Characteristics.ServiceLabelIndex,
          HAP.Characteristics.ServiceLabelNamespace,
          HAP.Characteristics.SlatType,
          HAP.Characteristics.StatusActive,
          HAP.Characteristics.StatusFault,
          HAP.Characteristics.StatusLowBattery,
          HAP.Characteristics.StatusTampered,
          HAP.Characteristics.SulphurDioxideDensity,
          HAP.Characteristics.SwingMode,
          HAP.Characteristics.TargetAirPurifierState,
          HAP.Characteristics.TargetDoorState,
          HAP.Characteristics.TargetFanState,
          HAP.Characteristics.TargetHeaterCoolerState,
          HAP.Characteristics.TargetHorizontalTiltAngle,
          HAP.Characteristics.TargetPosition,
          HAP.Characteristics.TargetRelativeHumidity,
          HAP.Characteristics.TargetTemperature,
          HAP.Characteristics.TargetTiltAngle,
          HAP.Characteristics.TargetVerticalTiltAngle,
          HAP.Characteristics.TemperatureDisplayUnits,
          HAP.Characteristics.Version,
          HAP.Characteristics.VOCDensity,
          HAP.Characteristics.Volume,
          HAP.Characteristics.WaterLevel
        ]
      ]
    ]
  end
end
