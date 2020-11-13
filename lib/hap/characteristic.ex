defmodule HAP.Characteristic do
  @moduledoc """
  Represents a single characteristic
  """

  defstruct type: nil, perms: [], format: nil, value: nil

  def accessories_tree(
        %__MODULE__{type: type, perms: perms, format: format, value: value},
        service_index,
        characteristic_index
      ) do
    if "pr" in perms do
      %{
        iid: HAP.IID.to_iid(service_index, characteristic_index),
        type: type,
        perms: perms,
        format: format,
        value: value
      }
    else
      %{
        iid: HAP.IID.to_iid(service_index, characteristic_index),
        type: type,
        perms: perms,
        format: format
      }
    end
  end

  def get_value(%__MODULE__{value: value}) do
    value
  end

  def put_value(%__MODULE__{} = characteristic, new_value) do
    IO.puts("Writing #{new_value} to #{characteristic.type}")
    :ok
  end
end
