use Mix.Config

config :nerves_dnssd,
  daemon_restart: :ignore

config :home_kit_ex,
  port: 4000,
  accessory: %{
    identifier: "11:22:33:44:55:66",
    name: "MatDevice",
    accessory_type: 12
  }
