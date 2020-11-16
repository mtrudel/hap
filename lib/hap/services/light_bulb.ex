defmodule HAP.Services.LightBulb do
  @moduledoc """
  Factory for the `public.hap.service.lightbulb` service
  """

  def build_service(mod, opts \\ []) do
    %HAP.Service{
      type: "43",
      characteristics: [HAP.Characteristics.On.build_characteristic(mod, opts)]
    }
  end
end
