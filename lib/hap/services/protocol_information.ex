defmodule HAP.Services.ProtocolInformation do
  def build_service(_opts \\ []) do
    %HAP.Service{
      type: "A2",
      characteristics: [
        HAP.Characteristics.Version.build_characteristic("1.1.0")
      ]
    }
  end
end
