defmodule HAP.Services.AirPurifier do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.air-purifier` service
  """

  defstruct active: nil,
            current_air_purifier_state: nil,
            target_air_purifier_state: nil,
            name: nil,
            rotation_speed: nil,
            swing_mode: nil,
            lock_physical_controls: nil

  defimpl HAP.ServiceSource do
    def compile(value) do
      HAP.Service.ensure_required!(__MODULE__, "active", value.active)
      HAP.Service.ensure_required!(__MODULE__, "current_air_purifier_state", value.current_air_purifier_state)
      HAP.Service.ensure_required!(__MODULE__, "target_air_purifier_state", value.target_air_purifier_state)

      %HAP.Service{
        type: "BB",
        characteristics: [
          {HAP.Characteristics.Active, value.active},
          {HAP.Characteristics.CurrentAirPurifierState, value.current_air_purifier_state},
          {HAP.Characteristics.TargetAirPurifierState, value.target_air_purifier_state},
          {HAP.Characteristics.Name, value.name},
          {HAP.Characteristics.RotationSpeed, value.rotation_speed},
          {HAP.Characteristics.SwingMode, value.swing_mode},
          {HAP.Characteristics.LockPhysicalControls, value.lock_physical_controls}
        ]
      }
    end
  end
end
