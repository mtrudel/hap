defmodule HAP.Services.Window do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.window` service
  """

  defstruct current_position: nil,
            target_position: nil,
            position_state: nil,
            name: nil,
            hold_position: nil,
            obstruction_detected: nil

  defimpl HAP.ServiceSource do
    def compile(value) do
      %HAP.Service{
        type: "8B",
        characteristics: [
          {HAP.Characteristics.CurrentPosition, value.current_position},
          {HAP.Characteristics.TargetPosition, value.target_position},
          {HAP.Characteristics.PositionState, value.position_state},
          {HAP.Characteristics.Name, value.name},
          {HAP.Characteristics.HoldPosition, value.hold_position},
          {HAP.Characteristics.ObstructionDetected, value.obstruction_detected}
        ]
      }
    end
  end
end
