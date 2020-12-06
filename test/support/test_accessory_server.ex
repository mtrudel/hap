defmodule HAP.Test.TestAccessoryServer do
  @moduledoc false

  def test_server(config \\ []) do
    accessory_server =
      %HAP.AccessoryServer{
        identifier: "11:22:33:44:55:66",
        display_module: HAP.Test.Display,
        data_path: Temp.mkdir!()
      }
      |> HAP.AccessoryServer.compile()
      |> struct(config)

    {HAP, accessory_server}
  end
end
