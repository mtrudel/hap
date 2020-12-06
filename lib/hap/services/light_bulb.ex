defmodule HAP.Services.LightBulb do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.lightbulb` service
  """

  defstruct on: nil

  defimpl HAP.ServiceSource do
    def compile(value) do
      %HAP.Service{
        type: "43",
        characteristics: [
          HAP.Characteristics.On.build_characteristic(value.on)
        ]
      }
    end
  end
end
