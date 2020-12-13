defmodule HAP.Services.OccupancySensor do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.sensor.occupancy` service
  """

  defstruct occupancy: nil, name: nil, active: nil, fault: nil, tampered: nil, low_battery: nil

  defimpl HAP.ServiceSource do
    def compile(value) do
      %HAP.Service{
        type: "86",
        characteristics: [
          {HAP.Characteristics.OccupancyDetected, value.occupancy},
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
