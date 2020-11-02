![HAP](https://user-images.githubusercontent.com/79646/67910894-dd4dc280-fb5a-11e9-9ca9-4be6633cc1a6.png)

HAP is a framework for building DIY HomeKit accessories based on Apple's [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/). 
You can think of it as [homebridge](https://www.github.com/nfarina/homebridge) for Elixir (with a bit more of a focus on
building actual accessories via Nerves) in contrast to Homebridge's typical use as a bridge to existing accessories.

HAP is **very** much a work in progress. It doesn't come close to working yet, but 
steady progress is being made:

* [x] Pair Setup
* [x] Pair Verification
* [ ] Encrypted Sessions
* [ ] Extra Pairing Actions (Add, Delete, List)
* [ ] Higher level bits (actual functionality)
* [ ] Events
* [ ] Identify

## Installation

Once a baseline level of functionality has been implemented, this library will 
be repackaged as a standard hex package for inclusion within any Elixir project 
(including Nerves projects). For the sake of expediency, while the core 
functionality is being built out the structure of this library is closer to 
a typical Elixir application. To use it while still in development, you can:

```
# Install an up to date Erlang as described in the next section
mix deps.get
iex -S mix
```

### Regarding crypto support in Erlang

In order to have access to the required crypto methods for HAP to function, a
fairly recent version of Erlang is required (23.0 or better).

Additionally, in order to have access to the `chacha20_poly1305` cipher that 
is required by HAP, Erlang needs to be linked aginst a version of OpenSSL newer
than 1.1.0. On recent macOS versions this [can be problematic](https://github.com/asdf-vm/asdf-erlang#dealing-with-openssl-issues-on-macos).
You'll need to manually install a suitable version of OpenSSL and link against it. 
If you're using homebrew and asdf, something like this will work nicely:

```
brew install openssl@1.1
export KERL_CONFIGURE_OPTIONS="--with-ssl=/usr/local/opt/openssl@1.1/"
asdf install # This will install from .tool-versions, which specifies the correct Erlang
```

