defmodule HAP.Characteristic do
  @moduledoc """
  Functions to aid in the manipulation of characteristics tuples
  """

  @typedoc """
  Represents a single characteristic optionally backed by an instance of ValueStore
  """
  @type t :: {module(), value_source()}

  @typedoc """
  Represents a source for a characteristic value. May be either a static literal or 
  a `{mod, opts}` tuple which is consulted when reading / writing a characteristic
  """
  @type value_source :: value() | {HAP.ValueStore.t(), value_opts: HAP.ValueStore.opts()}

  @typedoc """
  The resolved value of a characteristic
  """
  @type value :: any()

  @doc false
  def accessories_tree(
        {characteristic_definition, _value} = characteristic,
        service_index,
        characteristic_index,
        opts \\ []
      ) do
    iid = HAP.IID.to_iid(service_index, characteristic_index)
    type = characteristic_definition.type()
    perms = characteristic_definition.perms()
    format = characteristic_definition.format()

    cond do
      Keyword.get(opts, :static_only) -> %{iid: iid, type: type}
      "pr" in perms -> %{iid: iid, type: type, perms: perms, format: format, value: get_value(characteristic)}
      true -> %{iid: iid, type: type, perms: perms, format: format}
    end
  end

  @doc false
  def get_value({_definition, {mod, opts}}) do
    mod.get_value(opts)
  end

  @doc false
  def get_value({_definition, value}) do
    value
  end

  @doc false
  def put_value({_definition, {mod, opts}}, value) do
    mod.put_value(value, opts)
  end
end
