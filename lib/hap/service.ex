defmodule HAP.Service do
  @moduledoc """
  Represents a single service, containing a number of characteristics
  """

  defstruct type: nil, characteristics: []

  def accessories_tree(%__MODULE__{type: type, characteristics: characteristics}, service_index) do
    formatted_characteristics =
      characteristics
      |> Enum.with_index()
      |> Enum.map(fn {characteristic, characteristic_index} ->
        HAP.Characteristic.accessories_tree(characteristic, service_index, characteristic_index)
      end)

    %{iid: HAP.IID.to_iid(service_index), type: type, characteristics: formatted_characteristics}
  end

  def get_characteristic(%__MODULE__{characteristics: characteristics}, iid) do
    characteristics
    |> Enum.at(HAP.IID.characteristic_index(iid))
  end
end
