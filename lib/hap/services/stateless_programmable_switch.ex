defmodule HAP.Services.StatelessProgrammableSwitch do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.stateless-programmable-switch` service

  NOTE special requirements in specification for using Service Label (index) under various circumstances
  """

  defstruct input_event: nil, name: nil, service_label_index: nil

  defimpl HAP.ServiceSource do
    def compile(value) do
      HAP.Service.ensure_required!(__MODULE__, "input_event", value.input_event)

      %HAP.Service{
        type: "89",
        characteristics: [
          {HAP.Characteristics.InputEvent, value.input_event},
          {HAP.Characteristics.Name, value.name}
          {HAP.Characteristics.ServiceLabelIndex, value.service_label_index}
        ]
      }
    end
  end
end
