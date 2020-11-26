defmodule HAP do
  @moduledoc """
  Provides a high-level interface to an implementation of the HomeKit Accessory 
  Protocol, allowing an application to present any number of services & 
  characteristics of those services to an iOS HomeKit controller

  A typical use case is as follows:

  ```elixir
  hap_server_config =
    HAP.build_accessory_server(
      name: "My HAP Demo Device",
      model: "HAP Demo Device",
      identifier: "11:22:33:44:12:66",
      accessory_type: 5,
      accessories: [
        HAP.build_accessory(
          name: "HAP Lightbulb",
          model: "HAP Lightbulb",
          manufacturer: "HAP Inc.",
          serial_number: "123456",
          firmware_revision: "1.0",
          services: [
            HAP.Services.LightBulb.build_service(value_store_mod, value_store_opts)
          ]
        )
      ]
    )

  children =
    [ {HAP, hap_server_config} ]

    Supervisor.start_link(children, opts)

  ...
  ```
  """

  use Supervisor

  @doc """
  Starts a HAP instance based on the passed config
  """
  @spec start_link(HAP.AccessoryServer.t()) :: Supervisor.on_start()
  def start_link(config) do
    Supervisor.start_link(__MODULE__, config)
  end

  @doc """
  Builds an instance of `HAP.AccessoryServer` based on the provided information. 

  This function is typically called to build the input to a `HAP.start_link/1` call
  as in the example at the top of this file.

  Supported fields include:

  * `name`: The name to assign to this device, for example 'HAP Bridge'
  * `model`: The model name to assign to this accessory, for example 'HAP Bridge'
  * `identifier`: A unique identifier string in the form "AA:BB:CC:DD:EE:FF"
  * `pairing_code`: A pairing code of the form 123-45-678 to be used for pairing. 
  If not specified one will be defined dynamically.
  * `setup_id`: A 4 character string used as part of the accessory discovery process. 
  If not specified one will be defined dynamically.
  * `display_module`: An implementation of `HAP.Display` used to present pairing 
  and other information to the user. If not specified then `HAP.ConsoleDisplay` will
  be used
  * `data_path`: The path to where HAP will store its internal data. Will be created if
  it does not exist. If not specified, `hap_data` is used.
  * `accessory_type`: A HAP specified value indicating the primary function of this 
  device. See `t:HAP.AccessoryServer.accessory_type/0` for details
  * `accessories`: A list of accessories to include in this accessory server
  """
  @spec build_accessory_server(keyword()) :: HAP.AccessoryServer.t()
  defdelegate build_accessory_server(accessory_server), to: HAP.AccessoryServer

  @doc """
  Builds an instance of `HAP.Accessory` based on the provided information. The
  services passed in `services` will be included in the created accessory's list of
  services, as well as an instance of `Services.AccessoryInformation` and 
  `Services.ProtocolInformation` based on the extra provided metadata. 

  This function is typically called within a call to `HAP.build_accessory_server/1` 
  as in the example at the top of this file.

  Supported fields include:

  * `name`: The name to assign to this accessory, for example 'Ceiling Fan'
  * `model`: The model name to assign to this accessory, for example 'FanCo Whisper III'
  * `manufacturer`: The manufacturer of this accessory, for example 'FanCo'
  * `serial_number`: The serial number of this accessory, for example '0012345'
  * `firmware_revision`: The firmware revision of this accessory, for example '1.0'
  * `services`: A list of services to include in this accessory
  """
  @spec build_accessory(keyword()) :: HAP.Accessory.t()
  defdelegate build_accessory(accessory), to: HAP.Accessory

  def init(%HAP.AccessoryServer{} = config) do
    children = [
      {HAP.PersistentStorage, config.data_path},
      {HAP.AccessoryServerManager, config},
      HAP.PairSetup,
      {Bandit, plug: HAP.HTTPServer, options: [transport_module: HAP.HAPSessionTransport, port: config.port]}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
