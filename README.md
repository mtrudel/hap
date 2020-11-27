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

## Known Issues

As HAP is stil in active development, there are a number of known rough edges. These include:

* Only a few services & characteristics have been pre-defined (many more coming soon, though
note that in the interim you are always free to pass in any service / characteristic configuration you like. The
pre-defined values are just conveniences for common cases)
* Automatic configuration validation (coming soon)
* Type validation for characteristic values (coming soon)
* Improved support for pre-defined pairing codes (coming soon)
* No support for 207 Multi-Status responses to characteristic requests (coming soon)
* No support for asynchronous events (this is slated for HAP 2.0)
* Incomplete support for tearing down existing sessions on pairing removal (this is slated for HAP 2.0)
* No support for HomeKit Secure Video / RTP (support is not currently planned, but PRs are of course welcome)

In addition, there may well be bugs or gaps in functionality not listed above. If you encounter any, please feel free
to file an issue.

## Installation

HAP is available in Hex. The package can be installed by adding hap to your list of dependencies in mix.exs:

```
def deps do
  [
    {:hap, "~> 0.1.0"}
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
