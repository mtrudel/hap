defmodule HAP.Services.Television do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.television` service

  The Television service is used to control Apple TV and other television accessories
  through HomeKit. It supports features like power control, input switching, volume
  control, and remote control functionality.
  """

  defstruct active: nil,
            active_identifier: nil,
            configured_name: nil,
            sleep_discovery_mode: nil,
            brightness: nil,
            closed_captions: nil,
            display_order: nil,
            current_media_state: nil,
            target_media_state: nil,
            picture_mode: nil,
            power_mode_selection: nil,
            remote_key: nil,
            name: nil

  defimpl HAP.ServiceSource do
    def compile(value) do
      HAP.Service.ensure_required!(__MODULE__, "active", value.active)
      HAP.Service.ensure_required!(__MODULE__, "active_identifier", value.active_identifier)
      HAP.Service.ensure_required!(__MODULE__, "configured_name", value.configured_name)
      HAP.Service.ensure_required!(__MODULE__, "sleep_discovery_mode", value.sleep_discovery_mode)

      %HAP.Service{
        type: "D8",
        characteristics: [
          {HAP.Characteristics.Active, value.active},
          {HAP.Characteristics.ActiveIdentifier, value.active_identifier},
          {HAP.Characteristics.ConfiguredName, value.configured_name},
          {HAP.Characteristics.SleepDiscoveryMode, value.sleep_discovery_mode},
          {HAP.Characteristics.Brightness, value.brightness},
          {HAP.Characteristics.ClosedCaptions, value.closed_captions},
          {HAP.Characteristics.DisplayOrder, value.display_order},
          {HAP.Characteristics.CurrentMediaState, value.current_media_state},
          {HAP.Characteristics.TargetMediaState, value.target_media_state},
          {HAP.Characteristics.PictureMode, value.picture_mode},
          {HAP.Characteristics.PowerModeSelection, value.power_mode_selection},
          {HAP.Characteristics.RemoteKey, value.remote_key},
          {HAP.Characteristics.Name, value.name}
        ]
      }
    end
  end
end