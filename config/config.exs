import Config

if Mix.env() == :test do
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
end
