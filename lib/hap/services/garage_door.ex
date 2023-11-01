defmodule HAP.Services.GarageDoor do
  @moduledoc """
  Struct representing an instance of 'public.hap.service.garage_door.opener' service
  """

  defstruct current_door_state: nil,
            target_door_state: nil,
            name: nil,
            lock_current_state: nil,
            lock_target_state: nil,
            obstruction_detected: nil

  defimpl HAP.ServiceSource do
    def compile(value) do
      HAP.Service.ensure_required!(__MODULE__, "current_door_state", value.current_door_state)
      HAP.Service.ensure_required!(__MODULE__, "target_door_state", value.target_door_state)
      HAP.Service.ensure_required!(__MODULE__, "obstruction_detected", value.obstruction_detected)

      %HAP.Service{
        type: "41",
        characteristics: [
          {HAP.Characteristics.CurrentDoorState, value.current_door_state},
          {HAP.Characteristics.TargetDoorState, value.target_door_state},
          {HAP.Characteristics.ObstructionDetected, value.obstruction_detected},
          {HAP.Characteristics.Name, value.name},
          {HAP.Characteristics.LockCurrentState, value.lock_current_state},
          {HAP.Characteristics.LockTargetState, value.lock_target_state}
        ]
      }
    end
  end
end
