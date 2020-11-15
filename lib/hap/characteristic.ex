defmodule HAP.Characteristic do
  @moduledoc """
  Represents a single characteristic
  """

  defstruct type: nil, perms: [], format: nil, value: nil

  def accessories_tree(
        %__MODULE__{
          type: type,
          perms: perms,
          format: format,
          value: value
        },
        service_index,
        characteristic_index,
        opts \\ []
      ) do
    iid = HAP.IID.to_iid(service_index, characteristic_index)

    cond do
      Keyword.get(opts, :static_only) -> %{iid: iid, type: type}
      "pr" in perms -> %{iid: iid, type: type, perms: perms, format: format, value: value}
      true -> %{iid: iid, type: type, perms: perms, format: format}
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
