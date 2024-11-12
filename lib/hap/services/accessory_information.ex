defmodule HAP.Services.AccessoryInformation do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.accessory-information` service
  """

  @behaviour HAP.ValueStore

  defstruct accessory: nil

  defimpl HAP.ServiceSource do
    def compile(%HAP.Services.AccessoryInformation{accessory: %HAP.Accessory{} = accessory}) do
      %HAP.Service{
        type: "3E",
        characteristics: [
          {HAP.Characteristics.Name, accessory.name},
          {HAP.Characteristics.Model, accessory.model},
          {HAP.Characteristics.Manufacturer, accessory.manufacturer},
          {HAP.Characteristics.SerialNumber, accessory.serial_number},
          {HAP.Characteristics.FirmwareRevision, accessory.firmware_revision},
          {HAP.Characteristics.Identify, {HAP.Services.AccessoryInformation, name: accessory.name}}
        ]
      }
    end
  end

  @impl HAP.ValueStore
  def get_value(_) do
    raise "Cannot get value for identify"
  end

  @impl HAP.ValueStore
  def put_value(_value, name: name) do
    # identify is a GenServer call that otherwise would be calling its own process
    Task.start(fn -> HAP.Display.identify(name) end)
    :ok
  end
end
