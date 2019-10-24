# HAP

HAP is a framework for building DIY HomeKit accessories based on Apple's [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/). 
You can think of it as [homebridge](https://www.github.com/nfarina/homebridge) for Elixir.

HAP is **very** much a work in progress:

* [x] Pair Setup (nearly complete)
* [ ] Pair Verification
* [ ] Encrypted Sessions
* [ ] Extra Pairing Actions (Add, Delete, List)
* [ ] Higher level bits (actual functinoality)
* [ ] Events
* [ ] Identify

## Installation

TBD. Likely the core of this will end up being a Hex package that you pull into
a project similar to Phoenix. That approach would allow for easy integration with
Nerves, which is the most common use case for this library.
