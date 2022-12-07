defmodule HAP do
  @moduledoc """
  HAP is an implementation of the [HomeKit Accessory Protocol](https://developer.apple.com/homekit/) specification.
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
  changing light, it may also expose a Hue Characteristic. Within HAP, a characteristic is represented by a tuple of a
  `HAP.CharacteristicDefinition` and a value source.

  ## Using HAP

  HAP provides a high-level interface to the HomeKit Accessory Protocol, allowing an application to
  present any number of accessories to an iOS HomeKit controller. HAP is intended to be embedded within a host 
  application which is responsible for providing the actual backing implementations of the various characteristics
  exposed via HomeKit. These are provided to HAP in the form of `HAP.ValueStore` implementations.  For example, consider
  a Nerves application which exposes itself to HomeKit as a light bulb. Assume that the actual physical control of the
  light is controlled by GPIO pin 23. A typical configuration of HAP would look something like this:

  ```elixir
  accessory_server =
    %HAP.AccessoryServer{
      name: "My HAP Demo Device",
      model: "HAP Demo Device",
      identifier: "11:22:33:44:12:66",
      accessory_type: 5,
      accessories: [
        %HAP.Accessory{
          name: "My HAP Lightbulb",
          services: [
            %HAP.Services.LightBulb{on: {MyApp.Lightbulb, gpio_pin: 23}}
          ]
        }
      ]
    )

  children = [{HAP, accessory_server}]

  Supervisor.start_link(children, opts)

  ...
  ```

  In this example, the application developer is responsible for creating a `MyApp.Lightbulb` module which implements the `HAP.ValueStore`
  behaviour. This module would be called by HAP whenever it needs to change or query the current state of the light. The
  extra options (`gpio_pin: 23` in the above example) are conveyed to this module on every call, allowing a single value store
  implementation to service any number of characteristics or services.

  HAP provides structs to represent the most common services, such as light bulbs, switches, and other common device types.
  HAP compiles these structs into generic `HAP.Service` structs when starting up, based on each source struct's implementation
  of the `HAP.ServiceSource` protocol. This allows for expressive definition of services by the application developer, while
  providing for less boilerplate within HAP itself. For users who wish to create additional device types not defined in
  HAP, users may define their accessories in terms of low-level `HAP.Service` and `HAP.CharacteristicDefinition` structs. For more
  information, consult the type definitions for `t:HAP.AccessoryServer.t/0`, `t:HAP.Accessory.t/0`, `t:HAP.Service.t/0`,
  `t:HAP.Characteristic.t/0`, and the `HAP.CharacteristicDefinition` behaviour.
  """

  use Supervisor

  @doc """
  Starts a HAP instance based on the passed config
  """
  @spec start_link(HAP.AccessoryServer.t()) :: Supervisor.on_start()
  def start_link(config) do
    Supervisor.start_link(__MODULE__, config)
  end

  def init(%HAP.AccessoryServer{} = accessory_server) do
    accessory_server = accessory_server |> HAP.AccessoryServer.compile()

    children = [
      {HAP.PersistentStorage, accessory_server.data_path},
      {HAP.AccessoryServerManager, accessory_server},
      HAP.EventManager,
      HAP.PairSetup,
      {ThousandIsland,
       handler_module: HAP.HAPSessionHandler,
       handler_options: %{plug: {HAP.HTTPServer, []}},
       transport_module: HAP.HAPSessionTransport,
       port: 0}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end

  @doc """
  Called by user applications whenever a characteristic value has changed. The change token is passed to `HAP.ValueStore`
  instances via the `c:HAP.ValueStore.set_change_token/2` callback.
  """
  @spec value_changed(HAP.ValueStore.change_token()) :: :ok
  defdelegate value_changed(change_token), to: HAP.AccessoryServerManager
end
