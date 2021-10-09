defmodule HAP.Services.Faucet do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.faucet` service
  """

  defstruct active: nil, name: nil, fault: nil

  defimpl HAP.ServiceSource do
    def compile(value) do
      HAP.Service.ensure_required!(__MODULE__, "active", value.active)

      %HAP.Service{
        type: "D7",
        characteristics: [
          {HAP.Characteristics.Active, value.active},
          {HAP.Characteristics.Name, value.name},
          {HAP.Characteristics.StatusFault, value.fault}
        ]
      }
    end
  end
end
