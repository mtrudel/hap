![HAP](https://user-images.githubusercontent.com/79646/67910894-dd4dc280-fb5a-11e9-9ca9-4be6633cc1a6.png)

[![Build Status](https://github.com/mtrudel/hap/workflows/Elixir%20CI/badge.svg)](https://github.com/mtrudel/hap/actions)
[![Hex.pm](https://img.shields.io/hexpm/v/hap.svg?style=flat-square)](https://hex.pm/packages/hap)

[Documentation](https://hexdocs.pm/hap/)

HAP is a framework for building DIY HomeKit accessories based on Apple's [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/). 
You can think of it as [homebridge](https://github.com/nfarina/homebridge) for Elixir (with a bit more of a focus on
building actual accessories via Nerves) in contrast to Homebridge's typical use as a bridge to existing accessories.

As shown in the [HAP Demo](https://github.com/mtrudel/hap_demo) project, integrating HAP support into an existing Elixir
project is extremely straightforward - all that is required in most cases is to define the services and characteristics
you wish to expose, and to provide an implementation of `HAP.ValueStore` for each non-static characteristic you define.

In many cases, integrating with HAP can be as simple as:

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

## Supported Services & Characteristics

As originally developed, HAP included a fairly small set of services & characteristics (mostly due to the author's
laziness & the immediate need for only a handful of the ~45 services & ~128 characteristics defined in the
specification). However, it is quite easy to add definitions for new services & characteristics, and PRs to add such
definitions are extremely welcome. The [lightbulb service](https://github.com/mtrudel/hap/blob/master/lib/hap/services/light_bulb.ex) 
is a complete implementation of a service and serves as an excellent starting point for creating your own. You can consult
sections 8 and 9 of the [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/) to determine
what characteristics are required and optional for a given service. Note that only implementations of public services and
characteristcs as defined in the HomeKit specification will be considered for inclusion in HAP. 

## Known Issues

As HAP is stil in active development, there are a number of known rough edges. These include:

* No support for asynchronous events (this is slated for HAP 2.0)
* No support for dynamically updating the services advertised by a HAP instance (this is slated for HAP 2.0)
* Incomplete support for tearing down existing sessions on pairing removal (this is slated for HAP 2.0)
* No support for HomeKit Secure Video / RTP (support is not currently planned, but PRs are of course welcome)

In addition, there may well be bugs or gaps in functionality not listed above. If you encounter any, please feel free
to file an issue.

## Installation

HAP is available in Hex. The package can be installed by adding hap to your list of dependencies in mix.exs:

```
def deps do
  [
    {:hap, "~> 0.3.0"}
  ]
end
```

HAP is intended to be used within a host application which provides concrete implementations for various HomeKit
characteristics. Check out the [HAP Demo](https://github.com/mtrudel/hap_demo) app for an example of how to use HAP.

Documentation can be found at https://hexdocs.pm/hap/.

Note that in order to have access to the required crypto methods for HAP to function, at
least version 23.0 of Erlang is required.

## License

MIT
