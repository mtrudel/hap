defmodule HAP.Services.CarbonMonoxideSensor do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.sensor.carbon-monoxide` service
  """

  defstruct carbon_monoxide_detected: nil,
            carbon_monoxide_level: nil,
            carbon_monoxide_peak_level: nil,
            name: nil,
            active: nil,
            fault: nil,
            tampered: nil,
            low_battery: nil

  defimpl HAP.ServiceSource do
    def compile(value) do
      HAP.Service.ensure_required!(
        __MODULE__,
        "carbon_monoxide_detected",
        value.carbon_monoxide_detected
      )

      %HAP.Service{
        type: "7F",
        characteristics: [
          {HAP.Characteristics.CarbonMonoxideDetected, value.carbon_monoxide_detected},
          {HAP.Characteristics.CarbonMonoxideLevel, value.carbon_monoxide_level},
          {HAP.Characteristics.CarbonMonoxidePeakLevel, value.carbon_monoxide_peak_level},
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
