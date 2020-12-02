defmodule HAP do
  @moduledoc """
  HAP is an implementation of the [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/).
  It allows for the creation of Elixir powered HomeKit accessories which can be controlled from a user's
  iOS device in a similar manner to commercially available HomeKit accessories such as light bulbs, window 
  coverings and other smart home accessories.

  ## The HomeKit Data Model

  The data model of the HomeKit Accessory Protocol is represented as a tree structure. At the top level, a single HAP
  instance represents an *Accessory Server*.  An accessory server hosts one or more *Accessory Objects*. Each accessory object
  represents a single, discrete physical accessory. In the case of directly connected devices, an accessory server typically 
  hosts a single accessory object which represents device itself, whereas bridges will have one accessory object for each discrete 
  physical object which they bridge to. Within HAP, an accessory server is represented by a `HAP.AccessoryServer` struct, and
  an accessory by the `HAP.Accessory` struct.

  Each accessory object contains exposes a set of *Services*, each of which represents a unit of functionality.  As an 
  example, a HomeKit accessory server which represented a ceiling fan with a light would contain one accessory object 
  called 'Ceiling Fan', which would contain two services each representing the light and the fan. In addition to user-visible
  services, each accessory exposes an Accessory Information Service which contains information about the service's name, 
  manufacturer, serial number and other properties. Within HAP, a service is represented by a `HAP.Service` struct.

  A service is made up of one or more *Characteristics*, each of which represents a specific aspect of the given service. 
  For example, a light bulb service exposes an On Characteristic, which is a boolean value reflecting the current on or
  off state of the light. If it is a dimmable light, it may also expose a Brightness Characteristic. If it is a color
  changing light, it may also expose a Hue Characteristic. Within HAP, a characteristic is represented by a `HAP.Characteristic`
  struct.

  ## Using HAP

  HAP provides a high-level interface to the HomeKit Accessory Protocol, allowing an application to
  present any number of services & characteristics of those services to an iOS HomeKit controller. HAP is intended to be
  embedded within a host application which is responsible for providing the actual backing implementations of the
  various characteristics exposed via HomeKit. These are provided to HAP in the form of `HAP.ValueStore`
  implementations.  For example, consider a Nerves application which exposes itself to HomeKit as a light bulb. Assume that
  the actual physical control of the light is controlled by GPIO pin 23. A typical configuration of HAP would look something 
  like this:

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
            HAP.Services.LightBulb.build_service(MyApp.Lightbulb, gpio_pin: 23)
          ]
        )
      ]
    )

  children =
    [ {HAP, hap_server_config} ]

  Supervisor.start_link(children, opts)

  ...
  ```

  In this example, the application developer is responsible for creating a `MyApp.Lightbulb` module which implements the `HAP.ValueStore`
  behaviour. This module would be called by HAP whenever it needs to change or query the current state of the light. The
  extra options (`gpio_pin: 23` in the above example) are conveyed to this module on every call, allowing a single value store
  implementation to service any number of characteristics or services.

  HAP provides structs to represent the most common services, such as light bulbs, switches, and other common device types.
  For users who wish to create additional device types not defined in HAP, users may define their accessories in terms of
  low-level `HAP.Service` and `HAP.Characteristic` structs. For more information, consult the type definitions for 
  `t:HAP.AccessoryServer.t/0`, `t:HAP.Accessory.t/0`, `t:HAP.Service.t/0`, and `t:HAP.Characteristic.t/0`.
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
  * `display_module`: An optional implementation of `HAP.Display` used to present pairing 
  and other information to the user. If not specified then a basic console-based
  display is used.
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
