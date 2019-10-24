use Mix.Config

# TODO this is only needed in desktop environments
config :nerves_dnssd,
  daemon_restart: :ignore

config :hap,
  port: 4000,
  pairing_code: "111-22-333",
  accessory: %{
    identifier: "11:22:33:44:55:66",
    name: "MatDevice",
    accessory_type: 12
  }
