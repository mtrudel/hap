defmodule HAP.Services.Slat do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.vertical-slat` service
  """

  defstruct current_slat_state: nil,
            slat_type: nil,
            name: nil,
            swing_mode: nil,
            current_tilt_angle: nil,
            target_tilt_angle: nil

  defimpl HAP.ServiceSource do
    def compile(value) do
      HAP.Service.ensure_required!(__MODULE__, "current_slat_state", value.current_slat_state)
      HAP.Service.ensure_required!(__MODULE__, "slat_type", value.slat_type)

      %HAP.Service{
        type: "B9",
        characteristics: [
          {HAP.Characteristics.CurrentSlatState, value.current_slat_state},
          {HAP.Characteristics.SlatType, value.slat_type},
          {HAP.Characteristics.Name, value.name},
          {HAP.Characteristics.SwingMode, value.swing_mode},
          {HAP.Characteristics.CurrentTiltAngle, value.current_tilt_angle},
          {HAP.Characteristics.TargetTiltAngle, value.target_tilt_angle}
        ]
      }
    end
  end
end
