defmodule HAP.Characteristic do
  @moduledoc """
  Functions to aid in the manipulation of characteristics tuples
  """

  @typedoc """
  Represents a single characteristic consisting of a static definition and a value source
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
  def accessories_tree({characteristic_definition, value_source}, service_index, characteristic_index, opts \\ []) do
    iid = HAP.IID.to_iid(service_index, characteristic_index)
    type = characteristic_definition.type()
    perms = characteristic_definition.perms()
    format = characteristic_definition.format()

    cond do
      Keyword.get(opts, :static_only) ->
        %{iid: iid, type: type}

      "pr" not in perms ->
        %{iid: iid, type: type, perms: perms, format: format}

      true ->
        {:ok, value} = get_value_from_source(value_source)
        %{iid: iid, type: type, perms: perms, format: format, value: value}
    end
  end

  @doc false
  def get_value({characteristic_definition, value_source}) do
    if "pr" in characteristic_definition.perms() do
      get_value_from_source(value_source)
    else
      {:error, -70_405}
    end
  end

  @doc false
  def put_value({characteristic_definition, value_source}, value) do
    if "pw" in characteristic_definition.perms() do
      put_value_to_source(value_source, value)
    else
      {:error, -70_404}
    end
  end

  defp get_value_from_source({mod, opts}) do
    mod.get_value(opts)
  end

  defp get_value_from_source(value) do
    {:ok, value}
  end

  defp put_value_to_source({mod, opts}, value) do
    mod.put_value(value, opts)
  end

  defp put_value_to_source(_value, _new_value) do
    raise "Cannot write to a statically defined characteristic"
  end
end
