defmodule HAP.Services.WindowCovering do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.window-covering` service
  """

  defstruct current_position: nil,
            target_position: nil,
            position_state: nil,
            name: nil,
            hold_position: nil,
            current_horizontal_tilt_angle: nil,
            target_horizontal_tilt_angle: nil,
            current_vertical_tilt_angle: nil,
            target_vertical_tilt_angle: nil,
            obstruction_detected: nil

  defimpl HAP.ServiceSource do
    def compile(value) do
      %HAP.Service{
        type: "8C",
        characteristics: [
          {HAP.Characteristics.CurrentPosition, value.current_position},
          {HAP.Characteristics.TargetPosition, value.target_position},
          {HAP.Characteristics.PositionState, value.position_state},
          {HAP.Characteristics.Name, value.name},
          {HAP.Characteristics.HoldPosition, value.hold_position},
          {HAP.Characteristics.CurrentHorizontalTiltAngle, value.current_horizontal_tilt_angle},
          {HAP.Characteristics.TargetHorizontalTiltAngle, value.target_horizontal_tilt_angle},
          {HAP.Characteristics.CurrentVerticalTiltAngle, value.current_vertical_tilt_angle},
          {HAP.Characteristics.TargetVerticalTiltAngle, value.target_vertical_tilt_angle},
          {HAP.Characteristics.ObstructionDetected, value.obstruction_detected}
        ]
      }
    end
  end
end
