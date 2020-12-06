defmodule HAP.Services.ProtocolInformation do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.protocol.information.service` service
  """

  defstruct []

  defimpl HAP.ServiceSource do
    def compile(_value) do
      %HAP.Service{
        type: "A2",
        characteristics: [
          HAP.Characteristics.Version.build_characteristic("1.1.0")
        ]
      }
    end
  end
end
