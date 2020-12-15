defmodule HAP.IIDTest do
  use ExUnit.Case

  test "encodes & decodes service records properly" do
    assert HAP.IID.to_iid(123) |> HAP.IID.service_index() == {:ok, 123}
  end

  test "encodes service record 0 as iid 1" do
    assert HAP.IID.to_iid(123, 234) |> HAP.IID.service_index() == {:ok, 123}
    assert HAP.IID.to_iid(123, 234) |> HAP.IID.characteristic_index() == {:ok, 234}
  end

  test "encodes & decodes characteristic records properly" do
    assert HAP.IID.to_iid(0) == 1
  end
end
