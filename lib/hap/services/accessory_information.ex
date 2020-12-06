defmodule HAP.Services.AccessoryInformation do
  @moduledoc """
  Struct representing an instance of the `public.hap.service.accessory-information` service
  """

  defstruct accessory: nil

  defimpl HAP.ServiceSource do
    def compile(%HAP.Services.AccessoryInformation{accessory: %HAP.Accessory{} = accessory}) do
      %HAP.Service{
        type: "3E",
        characteristics: [
          HAP.Characteristics.Name.build_characteristic(accessory.name),
          HAP.Characteristics.Model.build_characteristic(accessory.model),
          HAP.Characteristics.Manufacturer.build_characteristic(accessory.manufacturer),
          HAP.Characteristics.SerialNumber.build_characteristic(accessory.serial_number),
          HAP.Characteristics.FirmwareRevision.build_characteristic(accessory.firmware_revision),
          HAP.Characteristics.Identify.build_characteristic(accessory.name)
        ]
      }
    end
  end
end
