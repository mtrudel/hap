defmodule HAP.Services.TelevisionSpeaker do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.television-speaker` service

  The TelevisionSpeaker service represents the audio output capabilities of a Television.
  It is typically linked to a Television service and provides volume control and mute functionality.
  """

  defstruct mute: nil,
            active: nil,
            volume_control_type: nil,
            volume_selector: nil,
            name: nil,
            volume: nil

  defimpl HAP.ServiceSource do
    def compile(value) do
      HAP.Service.ensure_required!(__MODULE__, "mute", value.mute)
      HAP.Service.ensure_required!(__MODULE__, "volume_control_type", value.volume_control_type)

      %HAP.Service{
        type: "113",
        characteristics: [
          {HAP.Characteristics.Mute, value.mute},
          {HAP.Characteristics.Active, value.active},
          {HAP.Characteristics.VolumeControlType, value.volume_control_type},
          {HAP.Characteristics.VolumeSelector, value.volume_selector},
          {HAP.Characteristics.Name, value.name},
          {HAP.Characteristics.Volume, value.volume}
        ]
      }
    end
  end
end
