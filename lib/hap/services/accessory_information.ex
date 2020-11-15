defmodule HAP.Services.AccessoryInformation do
  alias HAP.Characteristics

  def build_service(opts \\ []) do
    %HAP.Service{
      type: "3E",
      characteristics: [
        Characteristics.Name.build_characteristic(Keyword.get(opts, :name, "Generic HAP Service")),
        Characteristics.Model.build_characteristic(Keyword.get(opts, :model, "Generic HAP Model")),
        Characteristics.Manufacturer.build_characteristic(Keyword.get(opts, :manufacturer, "Generic HAP Manufacturer")),
        Characteristics.SerialNumber.build_characteristic(Keyword.get(opts, :serial_number, "Generic Serial Number")),
        Characteristics.FirmwareRevision.build_characteristic(Keyword.get(opts, :firmware_revision, "1.0")),
        Characteristics.Identify.build_characteristic()
      ]
    }
  end
end
