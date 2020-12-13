defmodule HAP.Services.MotionSensor do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.sensor.motion` service
  """

  defstruct motion: nil, name: nil, active: nil, fault: nil, tampered: nil, low_battery: nil

  defimpl HAP.ServiceSource do
    def compile(value) do
      %HAP.Service{
        type: "85",
        characteristics: [
          {HAP.Characteristics.MotionDetected, value.motion},
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
