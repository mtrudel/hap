defmodule HAP.Services.Thermostat do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.thermostat` service
  """

  defstruct cooling_threshold_temp: nil,
            current_humidity: nil,
            current_state: nil,
            current_temp: nil,
            heating_threshold_temp: nil,
            name: nil,
            target_humidity: nil,
            target_state: nil,
            target_temp: nil,
            temp_display_units: nil

  defimpl HAP.ServiceSource do
    def compile(value) do
      HAP.Service.ensure_required!(__MODULE__, "current_state", value.current_state)
      HAP.Service.ensure_required!(__MODULE__, "current_temp", value.current_temp)
      HAP.Service.ensure_required!(__MODULE__, "target_state", value.target_state)
      HAP.Service.ensure_required!(__MODULE__, "target_temp", value.target_temp)
      HAP.Service.ensure_required!(__MODULE__, "temp_display_units", value.temp_display_units)

      %HAP.Service{
        type: "4A",
        characteristics: [
          {HAP.Characteristics.CoolingThresholdTemperature, value.cooling_threshold_temp},
          {HAP.Characteristics.CurrentHeatingCoolingState, value.current_state},
          {HAP.Characteristics.CurrentRelativeHumidity, value.current_humidity},
          {HAP.Characteristics.CurrentTemperature, value.current_temp},
          {HAP.Characteristics.HeatingThresholdTemperature, value.heating_threshold_temp},
          {HAP.Characteristics.Name, value.name},
          {HAP.Characteristics.TargetHeatingCoolingState, value.target_state},
          {HAP.Characteristics.TargetRelativeHumidity, value.target_humidity},
          {HAP.Characteristics.TargetTemperature, value.target_temp},
          {HAP.Characteristics.TemperatureDisplayUnits, value.temp_display_units}
        ]
      }
    end
  end
end
