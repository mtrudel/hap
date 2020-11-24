defmodule HAP.Characteristic do
  @moduledoc """
  Represents a single characteristic
  """

  alias HAP.IID

  defstruct type: nil, perms: [], format: nil, value: nil, value_mod: nil, value_opts: []

  def accessories_tree(
        %__MODULE__{type: type, perms: perms, format: format} = characteristic,
        service_index,
        characteristic_index,
        opts \\ []
      ) do
    iid = IID.to_iid(service_index, characteristic_index)

    cond do
      Keyword.get(opts, :static_only) -> %{iid: iid, type: type}
      "pr" in perms -> %{iid: iid, type: type, perms: perms, format: format, value: get_value(characteristic)}
      true -> %{iid: iid, type: type, perms: perms, format: format}
    end
  end

  def get_value(%__MODULE__{value: value}) when not is_nil(value) do
    value
  end

  def get_value(%__MODULE__{value_mod: mod, value_opts: opts}) when not is_nil(mod) do
    # TODO -- type checking here
    mod.get_value(opts)
  end

  def put_value(%__MODULE__{value_mod: mod, value_opts: opts}, value) when not is_nil(mod) do
    # TODO -- type checking here
    mod.put_value(value, opts)
  end
end
