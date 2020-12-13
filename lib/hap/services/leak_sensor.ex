defmodule HAP.Services.LeakSensor do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.sensor.leak` service
  """

  defstruct leak: nil, name: nil, active: nil, fault: nil, tampered: nil, low_battery: nil

  defimpl HAP.ServiceSource do
    def compile(value) do
      HAP.Service.ensure_required!(__MODULE__, "leak", value.leak)

      %HAP.Service{
        type: "83",
        characteristics: [
          {HAP.Characteristics.LeakDetected, value.leak},
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
