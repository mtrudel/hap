defmodule HAP.Services.InputSource do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.input-source` service

  The InputSource service represents an individual input on a Television,
  such as HDMI ports, apps, or other input methods. Multiple InputSource
  services can be linked to a Television service.
  """

  defstruct configured_name: nil,
            input_source_type: nil,
            is_configured: nil,
            current_visibility_state: nil,
            identifier: nil,
            input_device_type: nil,
            name: nil,
            target_visibility_state: nil

  defimpl HAP.ServiceSource do
    def compile(value) do
      HAP.Service.ensure_required!(__MODULE__, "configured_name", value.configured_name)
      HAP.Service.ensure_required!(__MODULE__, "input_source_type", value.input_source_type)
      HAP.Service.ensure_required!(__MODULE__, "is_configured", value.is_configured)
      HAP.Service.ensure_required!(__MODULE__, "current_visibility_state", value.current_visibility_state)
      HAP.Service.ensure_required!(__MODULE__, "identifier", value.identifier)

      %HAP.Service{
        type: "D9",
        characteristics: [
          {HAP.Characteristics.ConfiguredName, value.configured_name},
          {HAP.Characteristics.InputSourceType, value.input_source_type},
          {HAP.Characteristics.IsConfigured, value.is_configured},
          {HAP.Characteristics.CurrentVisibilityState, value.current_visibility_state},
          {HAP.Characteristics.Identifier, value.identifier},
          {HAP.Characteristics.InputDeviceType, value.input_device_type},
          {HAP.Characteristics.Name, value.name},
          {HAP.Characteristics.TargetVisibilityState, value.target_visibility_state}
        ]
      }
    end
  end
end
