defmodule HAP.Services.SmokeSensor do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.sensor.smoke` service
  """

  defstruct smoke_detected: nil, name: nil, active: nil, fault: nil, tampered: nil, low_battery: nil

  defimpl HAP.ServiceSource do
    def compile(value) do
      HAP.Service.ensure_required!(__MODULE__, "smoke_detected", value.smoke_detected)

      %HAP.Service{
        type: "87",
        characteristics: [
          {HAP.Characteristics.SmokeDetected, value.smoke_detected},
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
