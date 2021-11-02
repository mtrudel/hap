defmodule HAP.Services.AirQualitySensor do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.sensor.air-quality` service
  """

  defstruct air_quality: nil, name: nil, active: nil, fault: nil, tampered: nil, low_battery: nil

  defimpl HAP.ServiceSource do
    def compile(value) do
      HAP.Service.ensure_required!(__MODULE__, "air_quality", value.air_quality)

      %HAP.Service{
        type: "8A",
        characteristics: [
          {HAP.Characteristics.AirQuality, value.air_quality},
          {HAP.Characteristics.Name, value.name},
          # TODO: The following optional characteristics still have to be implemented
          # ”9.71 Ozone Density” (page 191)
          # ”9.64 Nitrogen Dioxide Density” (page 189)
          # ”9.106 Sulphur Dioxide Density” (page 221)
          # ”9.66 PM2.5 Density” (page 190)
          # ”9.72 PM10 Density” (page 192)
          # ”9.126 VOC Density” (page 233)
          {HAP.Characteristics.StatusActive, value.active},
          {HAP.Characteristics.StatusFault, value.fault},
          {HAP.Characteristics.StatusTampered, value.tampered},
          {HAP.Characteristics.StatusLowBattery, value.low_battery}
        ]
      }
    end
  end
end
