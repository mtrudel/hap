defmodule HAP.Accessory do
  @moduledoc """
  Represents a single accessory object, containing a number of services
  """

  defstruct name: "Generic HAP Accessory",
            model: "Generic HAP Model",
            manufacturer: "Generic HAP Manufacturer",
            serial_number: "Generic Serial Number",
            firmware_revision: "1.0",
            services: []

  @typedoc """
  Represents an accessory consisting of a number of services. Contains the following
  fields:

  * `name`: The name to assign to this accessory, for example 'Ceiling Fan'
  * `model`: The model name to assign to this accessory, for example 'FanCo Whisper III'
  * `manufacturer`: The manufacturer of this accessory, for example 'FanCo'
  * `serial_number`: The serial number of this accessory, for example '0012345'
  * `firmware_revision`: The firmware revision of this accessory, for example '1.0'
  * `services`: A list of services to include in this accessory
  """
  @type t :: %__MODULE__{
          name: name(),
          model: model(),
          manufacturer: manufacturer(),
          serial_number: serial_number(),
          firmware_revision: firmware_revision(),
          services: [HAP.Service.t()]
        }

  @typedoc """
  The name to advertise for this accessory, for example 'HAP Light Bulb'
  """
  @type name :: String.t()

  @typedoc """
  The model of this accessory, for example 'HAP Light Bulb Supreme'
  """
  @type model :: String.t()

  @typedoc """
  The manufacturer of this accessory, for example 'HAP Co.'
  """
  @type manufacturer :: String.t()

  @typedoc """
  The serial number of this accessory, for example '0012345'
  """
  @type serial_number :: String.t()

  @typedoc """
  The firmware recvision of this accessory, for example '1.0' or '1.0.1'
  """
  @type firmware_revision :: String.t()

  @doc false
  def compile(%__MODULE__{services: services} = accessory) do
    all_services =
      [%HAP.Services.AccessoryInformation{accessory: accessory}, %HAP.Services.ProtocolInformation{}] ++
        services

    %__MODULE__{
      services: all_services |> Enum.map(&HAP.ServiceSource.compile/1)
    }
  end

  @doc false
  def accessories_tree(%__MODULE__{services: services}, aid, opts \\ []) do
    formatted_services =
      services
      |> Enum.with_index()
      |> Enum.map(fn {service, service_index} ->
        HAP.Service.accessories_tree(service, service_index, opts)
      end)

    %{aid: aid, services: formatted_services}
  end

  @doc false
  def get_characteristic(%__MODULE__{services: services}, iid) do
    services
    |> Enum.at(HAP.IID.service_index(iid))
    |> HAP.Service.get_characteristic(iid)
  end
end
