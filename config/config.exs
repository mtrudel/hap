import Config

if Mix.env() == :test do
  config :mdns_lite, skip_udp: true
end
