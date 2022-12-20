defmodule HAP.Services.Speaker do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.speaker` service
  """

  defstruct mute: nil, name: nil, volume: nil

  defimpl HAP.ServiceSource do
    def compile(value) do
      HAP.Service.ensure_required!(__MODULE__, "mute", value.mute)

      %HAP.Service{
        type: "113",
        characteristics: [
          {HAP.Characteristics.Mute, value.mute},
          {HAP.Characteristics.Name, value.name},
          {HAP.Characteristics.Volume, value.volume}
        ]
      }
    end
  end
end
