defmodule HAP.Services.AccessoryInformation do
  @moduledoc """
  Factory for the `public.hap.service.accessory-information` service
  """

  @behaviour HAP.ValueStore

  alias HAP.Characteristics

  def build_service(opts \\ []) do
    %HAP.Service{
      type: "3E",
      characteristics: [
        Characteristics.Name.build_characteristic(Keyword.get(opts, :name, "Generic HAP Accessory")),
        Characteristics.Model.build_characteristic(Keyword.get(opts, :model, "Generic HAP Model")),
        Characteristics.Manufacturer.build_characteristic(Keyword.get(opts, :manufacturer, "Generic HAP Manufacturer")),
        Characteristics.SerialNumber.build_characteristic(Keyword.get(opts, :serial_number, "Generic Serial Number")),
        Characteristics.FirmwareRevision.build_characteristic(Keyword.get(opts, :firmware_revision, "1.0")),
        Characteristics.Identify.build_characteristic(__MODULE__,
          name: Keyword.get(opts, :name, "Generic HAP Accessory")
        )
      ]
    }
  end

  @impl HAP.ValueStore
  def get_value(_) do
    raise "Cannot get value for identify"
  end

  @impl HAP.ValueStore
  def put_value(_value, name: name) do
    HAP.Display.identify(name)
  end
end
