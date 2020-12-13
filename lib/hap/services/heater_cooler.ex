defmodule HAP.Services.HeaterCooler do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.heater-cooler` service
  """

  defstruct active: nil,
            current_temp: nil,
            current_state: nil,
            target_state: nil,
            name: nil,
            rotation_speed: nil,
            temp_display_units: nil,
            swing_mode: nil,
            cooling_threshold_temp: nil,
            heating_threshold_temp: nil,
            lock_physical_controls: nil

  defimpl HAP.ServiceSource do
    def compile(value) do
      %HAP.Service{
        type: "BC",
        characteristics: [
          {HAP.Characteristics.Active, value.active},
          {HAP.Characteristics.CurrentTemperature, value.current_temp},
          {HAP.Characteristics.CurrentHeaterCoolerState, value.current_state},
          {HAP.Characteristics.TargetHeaterCoolerState, value.target_state},
          {HAP.Characteristics.Name, value.name},
          {HAP.Characteristics.RotationSpeed, value.rotation_speed},
          {HAP.Characteristics.TemperatureDisplayUnits, value.temp_display_units},
          {HAP.Characteristics.SwingMode, value.swing_mode},
          {HAP.Characteristics.CoolingThresholdTemperature, value.cooling_threshold_temp},
          {HAP.Characteristics.HeatingThresholdTemperature, value.heating_threshold_temp},
          {HAP.Characteristics.LockPhysicalControls, value.lock_physical_controls}
        ]
      }
    end
  end
end
