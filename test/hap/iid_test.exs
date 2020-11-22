defmodule HAP.IIDTest do
  use ExUnit.Case

  alias HAP.IID

  test "encodes & decodes service records properly" do
    assert IID.to_iid(123) |> IID.service_index() == 123
  end

  test "encodes service record 0 as iid 1" do
    assert IID.to_iid(123, 234) |> IID.service_index() == 123
    assert IID.to_iid(123, 234) |> IID.characteristic_index() == 234
  end

  test "encodes & decodes characteristic records properly" do
    assert IID.to_iid(0) == 1
  end
end
