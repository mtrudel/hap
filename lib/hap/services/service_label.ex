defmodule HAP.Services.ServiceLabel do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.service-label` service
  """

  defstruct service_label_namespace: nil

  defimpl HAP.ServiceSource do
    def compile(value) do
      HAP.Service.ensure_required!(__MODULE__, "service_label_namespace", value.service_label_namespace)

      %HAP.Service{
        type: "CC",
        characteristics: [
          {HAP.Characteristics.ServiceLabelNamespace, value.service_label_namespace}
        ]
      }
    end
  end
end
