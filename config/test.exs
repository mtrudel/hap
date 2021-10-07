import Config

config :mdns_lite, skip_udp: true

# import vintage_net test config, to enable tests to work on various env
# https://github.com/nerves-networking/vintage_net/blob/main/config/config.exs
config :vintage_net,
  udhcpc_handler: VintageNetTest.CapturingUdhcpcHandler,
  udhcpd_handler: VintageNetTest.CapturingUdhcpdHandler,
  interface_renamer: VintageNetTest.CapturingInterfaceRenamer,
  resolvconf: "/dev/null",
  path: "#{File.cwd!()}/test/fixtures/root/bin",
  persistence_dir: "./test_tmp/persistence",
  power_managers: [
    {VintageNetTest.TestPowerManager, [ifname: "test0", watchdog_timeout: 50]},
    {VintageNetTest.BadPowerManager, [ifname: "bad_power0"]},
    {NonExistentPowerManager, [ifname: "test_does_not_exist_case"]}
  ]
