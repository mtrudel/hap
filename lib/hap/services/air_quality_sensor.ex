defmodule HAP.Services.AirQualitySensor do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.sensor.air-quality` service
  """

  defstruct air_quality: nil,
            name: nil,
            ozone_density: nil,
            nitrogen_dioxide_density: nil,
            sulphur_dioxide_density: nil,
            pm2_5_density: nil,
            pm10_density: nil,
            voc_density: nil,
            active: nil,
            fault: nil,
            tampered: nil,
            low_battery: nil

  defimpl HAP.ServiceSource do
    def compile(value) do
      HAP.Service.ensure_required!(__MODULE__, "air_quality", value.air_quality)

      %HAP.Service{
        type: "8D",
        characteristics: [
          {HAP.Characteristics.AirQuality, value.air_quality},
          {HAP.Characteristics.Name, value.name},
          {Hap.Characteristics.OzoneDensity, value.ozone_density},
          {HAP.Characteristics.NitrogenDioxideDensity, value.nitrogen_dioxide_density},
          {HAP.Characteristics.SulphurDioxideDensity, value.sulphur_dioxide_density},
          {HAP.Characteristics.PM25Density, value.pm2_5_density},
          {HAP.Characteristics.PM10Density, value.pm10_density},
          {HAP.Characteristics.VOCDensity, value.voc_density},
          {HAP.Characteristics.StatusActive, value.active},
          {HAP.Characteristics.StatusFault, value.fault},
          {HAP.Characteristics.StatusTampered, value.tampered},
          {HAP.Characteristics.StatusLowBattery, value.low_battery}
        ]
      }
    end
  end
end
