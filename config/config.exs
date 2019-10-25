use Mix.Config

# TODO this is only needed in desktop environments
config :nerves_dnssd,
  daemon_restart: :ignore

config :hap,
  accessory: %{
    # Spaces can be tricky in the name, best to avoid
    name: "MatDevice",

    # This needs to be unique for every instance
    identifier: "11:22:33:44:55:66",

    # Optional: if omitted, pairing code will be randomly generated
    # pairing_code: "111-22-333",

    # Describes the principal function of this accessory
    # Valid values include:
    #
    # 1: Other
    # 2: Bridge
    # 3: Fan
    # 4: Garage
    # 5: Lightbulb
    # 6; Door Lock
    # 7: Outlet
    # 8: Switch
    # 9: Thermostat
    # 10: Sensor
    # 11: Security System
    # 12: Door
    # 13: Window
    # 14: Window Covering
    # 15: Programmable Switch
    # 16: Range Extender
    # 17: IP Camera
    # 18: Video Door Bell
    # 19: Air Purifier    
    accessory_type: 12
  }
