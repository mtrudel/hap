defmodule HAP.Services.ProtocolInformation do
  @moduledoc """
  Factory for the `public.hap.service.protocol.information.service` service
  """

  def build_service(_opts \\ []) do
    %HAP.Service{
      type: "A2",
      characteristics: [
        HAP.Characteristics.Version.build_characteristic("1.1.0")
      ]
    }
  end
end
