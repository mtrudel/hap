defmodule HAP.Services.LightBulb do
  @moduledoc """
  Factory for the `public.hap.service.lightbulb` service
  """

  alias HAP.{Characteristics, Service}

  def build_service(mod, opts \\ []) do
    %Service{
      type: "43",
      characteristics: [Characteristics.On.build_characteristic(mod, opts)]
    }
  end
end
