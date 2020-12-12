defmodule HAP.Services.LightBulb do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.lightbulb` service
  """

  defstruct on: nil, brightness: nil, hue: nil, name: nil, saturation: nil, color_temperature: nil

  defimpl HAP.ServiceSource do
    def compile(value) do
      %HAP.Service{
        type: "43",
        characteristics: [
          {HAP.Characteristics.On, value.on},
          {HAP.Characteristics.Brightness, value.brightness},
          {HAP.Characteristics.Hue, value.hue},
          {HAP.Characteristics.Name, value.name},
          {HAP.Characteristics.Saturation, value.saturation},
          {HAP.Characteristics.ColorTemperature, value.color_temperature}
        ]
      }
    end
  end
end
