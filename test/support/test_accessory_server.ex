defmodule HAP.Test.TestAccessoryServer do
  def test_server do
    {HAP,
     HAP.build_accessory_server(
       identifier: "11:22:33:44:55:66",
       display_module: HAP.Test.Display,
       data_path: Temp.mkdir!()
     )}
  end
end
