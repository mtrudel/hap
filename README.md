# HAP

HAP is a framework for building DIY HomeKit accessories based on Apple's [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/). 
You can think of it as [homebridge](https://www.github.com/nfarina/homebridge) for Elixir (and therefore also for
Nerves)

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

### Proper OpenSSL support on macOS in Erlang

In order to have access to the `chacha20_poly1305` cipher that is required by HAP, 
Erlang needs to be linked aginst a version of OpenSSL newer than 1.1.0. On recent
macOS versions this [can be problematic](https://github.com/asdf-vm/asdf-erlang#dealing-with-openssl-issues-on-macos).
You'll need to manually install a suitable version of OpenSSL and link against it. 
If you're using homebrew and asdf, something like this will work nicely:

```
> brew install openssl@1.1
> export KERL_CONFIGURE_OPTIONS="--with-ssl=/usr/local/opt/openssl@1.1/"
> asdf install erlang
```

