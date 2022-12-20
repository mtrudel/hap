defmodule HAP.Services.Door do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.door` service
  """

  defstruct current_position: nil,
            target_position: nil,
            position_state: nil,
            name: nil,
            hold_position: nil,
            obstruction_detected: nil

  defimpl HAP.ServiceSource do
    def compile(value) do
      HAP.Service.ensure_required!(__MODULE__, "current_position", value.current_position)
      HAP.Service.ensure_required!(__MODULE__, "target_position", value.target_position)
      HAP.Service.ensure_required!(__MODULE__, "position_state", value.position_state)

      %HAP.Service{
        type: "81",
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
