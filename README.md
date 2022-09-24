![HAP](https://user-images.githubusercontent.com/79646/67910894-dd4dc280-fb5a-11e9-9ca9-4be6633cc1a6.png)

[![Build Status](https://github.com/mtrudel/hap/workflows/Elixir%20CI/badge.svg)](https://github.com/mtrudel/hap/actions)
[![Docs](https://img.shields.io/badge/api-docs-green.svg?style=flat)](https://hexdocs.pm/hap)
[![Hex.pm](https://img.shields.io/hexpm/v/hap.svg?style=flat&color=blue)](https://hex.pm/packages/hap)

HAP is a framework for building DIY HomeKit accessories based on Apple's [HomeKit Accessory Protocol](https://developer.apple.com/homekit/) specification. 
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
definitions are extremely welcome. The [lightbulb service](https://github.com/mtrudel/hap/blob/main/lib/hap/services/light_bulb.ex) 
is a complete implementation of a service and serves as an excellent starting point for creating your own. You can consult
sections 8 and 9 of the [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/) to determine
what characteristics are required and optional for a given service. Note that only implementations of public services and
characteristics as defined in the HomeKit specification will be considered for inclusion in HAP. 

### Asynchronous Change Notifications

HAP supports notifications (as defined in section 6.8 of the [HomeKit Accessory Protocol
Specification](https://developer.apple.com/homekit/)). This allows your accessory to notify HomeKit of changes which
happen asynchronously, such as a user pushing a button on the accessory, or a sensor detecting a water leak. To send
such notifications, your `HAP.ValueStore` implementation must support the `c:HAP.ValueStore.set_change_token/2`
callback. Consult the `HAP.ValueStore` documentation for more detail.

## Known Issues

As HAP is still in active development, there are a number of known rough edges. These include:

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
    {:hap, "~> 0.4.0"}
  ]
end
```

HAP is intended to be used within a host application which provides concrete implementations for various HomeKit
characteristics. Check out the [HAP Demo](https://github.com/mtrudel/hap_demo) app for an example of how to use HAP.

Documentation can be found at https://hexdocs.pm/hap/.

Note that in order to have access to the required crypto methods for HAP to function, OTP 23 or newer is required. Also note that OTP 25.0.x has a [defect](https://github.com/erlang/otp/issues/6313) that breaks HAP (fixed in OTP 25.1 and newer).

Also note that although we still support Elixir 1.11, use of the Kino display module requires Elixir 1.12 or newer.

## License

MIT
