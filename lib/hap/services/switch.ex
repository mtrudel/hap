defmodule HAP.Services.Switch do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.switch` service
  """

  defstruct on: nil, name: nil

  defimpl HAP.ServiceSource do
    def compile(value) do
      %HAP.Service{
        type: "49",
        characteristics: [
          {HAP.Characteristics.On, value.on},
          {HAP.Characteristics.Name, value.name}
        ]
      }
    end
  end
end
