defmodule HAP.Services.LightSensor do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.sensor.light` service
  """

  defstruct light_level: nil, name: nil, active: nil, fault: nil, tampered: nil, low_battery: nil

  defimpl HAP.ServiceSource do
    def compile(value) do
      HAP.Service.ensure_required!(__MODULE__, "light_level", value.light_level)

      %HAP.Service{
        type: "84",
        characteristics: [
          {HAP.Characteristics.CurrentAmbientLightLevel, value.light_level},
          {HAP.Characteristics.Name, value.name},
          {HAP.Characteristics.StatusActive, value.active},
          {HAP.Characteristics.StatusFault, value.fault},
          {HAP.Characteristics.StatusTampered, value.tampered},
          {HAP.Characteristics.StatusLowBattery, value.low_battery}
        ]
      }
    end
  end
end
