defmodule HAP.Services.DoorBell do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.doorbell` service
  """

  defstruct input_event: nil,
            name: nil,
            volume: nil,
            brightness: nil

  defimpl HAP.ServiceSource do
    def compile(value) do
      HAP.Service.ensure_required!(__MODULE__, "input_event", value.input_event)

      %HAP.Service{
        type: "121",
        characteristics: [
          {HAP.Characteristics.InputEvent, value.input_event},
          {HAP.Characteristics.Name, value.name},
          {HAP.Characteristics.Volume, value.volume},
          {HAP.Characteristics.Brightness, value.brightness}
        ]
      }
    end
  end
end
