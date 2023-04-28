defmodule HAP.Services.FanV2 do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.fanv2` service
  """

  defstruct active: nil,
            name: nil,
            current_fan_state: nil,
            rotation_direction: nil,
            rotation_speed: nil,
            swing_mode: nil,
            lock_physical_controls: nil

  defimpl HAP.ServiceSource do
    def compile(value) do
      HAP.Service.ensure_required!(__MODULE__, "active", value.active)

      %HAP.Service{
        type: "B7",
        characteristics: [
          {HAP.Characteristics.Active, value.active},
          {HAP.Characteristics.Name, value.name},
          {HAP.Characteristics.CurrentFanState, value.current_fan_state},
          {HAP.Characteristics.RotationDirection, value.rotation_direction},
          {HAP.Characteristics.RotationSpeed, value.rotation_speed},
          {HAP.Characteristics.SwingMode, value.swing_mode},
          {HAP.Characteristics.LockPhysicalControls, value.lock_physical_controls}
        ]
      }
    end
  end
end
