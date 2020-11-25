defmodule HAP.Test.TestAccessoryServer do
  @moduledoc false

  def test_server(config \\ []) do
    {HAP,
     [identifier: "11:22:33:44:55:66", display_module: HAP.Test.Display, data_path: Temp.mkdir!()]
     |> Keyword.merge(config)
     |> HAP.build_accessory_server()}
  end
end
