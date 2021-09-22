defmodule HAP.Services.HumiditySensor do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.sensor.humidity` service
  """

  defstruct current_relative_humidity: nil, name: nil, active: nil, fault: nil, tampered: nil, low_battery: nil

  defimpl HAP.ServiceSource do
    def compile(value) do
      HAP.Service.ensure_required!(__MODULE__, "current_relative_humidity", value.current_relative_humidity)

      %HAP.Service{
        type: "82",
        characteristics: [
          {HAP.Characteristics.CurrentRelativeHumidity, value.current_relative_humidity},
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
