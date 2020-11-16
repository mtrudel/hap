![HAP](https://user-images.githubusercontent.com/79646/67910894-dd4dc280-fb5a-11e9-9ca9-4be6633cc1a6.png)

HAP is a framework for building DIY HomeKit accessories based on Apple's [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/). 
You can think of it as [homebridge](https://github.com/nfarina/homebridge) for Elixir (with a bit more of a focus on
building actual accessories via Nerves) in contrast to Homebridge's typical use as a bridge to existing accessories.

As shown in the [HAP Demo](https://github.com/mtrudel/hap_demo) project, integrating HAP support into an existing Elixir
project is extremely straightforward - all that is required in most cases is to define the services and characteristics
you wish to expose, and to provide an implementation of `HAP.ValueStore` for each non-static characteristic you define.

## Known Issues

As HAP is stil in active development, there are a number of known rough edges. These include:

* More coverage of common services & characteristics (coming soon)
* Automatic configuration validation (coming soon)
* Type validation for characteristic values (coming soon)
* Improved support for pre-defined pairing codes (coming soon)
* Non-existant documentation & tests (coming soon)
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


Documentation can be found at https://hexdocs.pm/hap.

Note that in order to have access to the required crypto methods for HAP to function, a
fairly recent version of Erlang is required (23.0 or better).

## License

MIT
