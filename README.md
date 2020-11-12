![HAP](https://user-images.githubusercontent.com/79646/67910894-dd4dc280-fb5a-11e9-9ca9-4be6633cc1a6.png)

HAP is a framework for building DIY HomeKit accessories based on Apple's [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/). 
You can think of it as [homebridge](https://github.com/nfarina/homebridge) for Elixir (with a bit more of a focus on
building actual accessories via Nerves) in contrast to Homebridge's typical use as a bridge to existing accessories.

HAP is **very** much a work in progress. It doesn't come close to working yet, but 
steady progress is being made:

* [x] Pair Setup
* [x] Pair Verification
* [x] Encrypted Sessions
* [x] Extra Pairing Actions (Add, Delete, List)
* [ ] Higher level bits (actual functionality)
* [ ] Identify
* [ ] Events

## Installation

HAP is packaged as a hex package and is intended to be used within a host application
which provides concrete implementations for various HomeKit characteristics. Check out 
the [HAP Demo](https://github.com/mtrudel/hap_demo) app for an example of how to use HAP.

Note that in order to have access to the required crypto methods for HAP to function, a
fairly recent version of Erlang is required (23.0 or better).
