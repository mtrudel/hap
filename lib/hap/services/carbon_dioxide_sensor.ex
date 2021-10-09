defmodule HAP.Services.CarbonDioxideSensor do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.sensor.carbon-dioxide` service
  """

  defstruct carbon_dioxide_detected: nil,
            carbon_dioxide_level: nil,
            carbon_dioxide_peak_level: nil,
            name: nil,
            active: nil,
            fault: nil,
            tampered: nil,
            low_battery: nil

  defimpl HAP.ServiceSource do
    def compile(value) do
      HAP.Service.ensure_required!(
        __MODULE__,
        "carbon_dioxide_detected",
        value.carbon_dioxide_detected
      )

      %HAP.Service{
        type: "97",
        characteristics: [
          {HAP.Characteristics.CarbonDioxideDetected, value.carbon_dioxide_detected},
          {HAP.Characteristics.CarbonDioxideLevel, value.carbon_dioxide_level},
          {HAP.Characteristics.CarbonDioxidePeakLevel, value.carbon_dioxide_peak_level},
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
