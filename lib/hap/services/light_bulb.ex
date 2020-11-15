defmodule HAP.Services.LightBulb do
  def build_service(_opts \\ []) do
    %HAP.Service{
      type: "43",
      characteristics: [
        HAP.Characteristics.On.build_characteristic(true)
      ]
    }
  end
end
