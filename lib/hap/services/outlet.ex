defmodule HAP.Services.Outlet do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.outlet` service
  """

  defstruct on: nil, outlet_in_use: nil, name: nil

  defimpl HAP.ServiceSource do
    def compile(value) do
      HAP.Service.ensure_required!(__MODULE__, "on", value.on)
      HAP.Service.ensure_required!(__MODULE__, "outlet_in_use", value.outlet_in_use)

      %HAP.Service{
        type: "47",
        characteristics: [
          {HAP.Characteristics.On, value.on},
          {HAP.Characteristics.OutletInUse, value.outlet_in_use},
          {HAP.Characteristics.Name, value.name}
        ]
      }
    end
  end
end
