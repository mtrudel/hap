defmodule HAP.Characteristic do
  @moduledoc """
  Represents a single characteristic optionally backed by an instance of ValueStore
  """

  defstruct type: nil, perms: [], format: nil, value: nil, value_mod: nil, value_opts: []

  @typedoc """
  Represents a single characteristic optionally backed by an instance of ValueStore
  """
  @type t :: %__MODULE__{
          type: type(),
          perms: [perm()],
          format: format(),
          value: value() | {HAP.ValueStore.t(), value_opts: HAP.ValueStore.opts()}
        }

  @typedoc """
  The type of a characteristic as defined in Section 6.6.1 of Apple's [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/).
  """
  @type type :: String.t()

  @typedoc """
  A permission of a characteristic as defined in Table 6.4 of Apple's [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/).
  One of `pr`, `pw`, `ev`, `aa`, `tw`, `hd`, or `wr`
  """
  @type perm :: String.t()

  @typedoc """
  The format of a characteristic as defined in Table 6.5 of Apple's [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/).
  One of `bool`, `uint8`, `uint16`, `uint32`, `uint64`, `int`, `float`, `string`, `tlv8`, or `data`
  """
  @type format :: String.t()

  @typedoc """
  The value of a characrteristic
  """
  @type value :: any()

  @doc false
  def compile({_characrteristic, nil}) do
    nil
  end

  def compile({characteristic_mod, value}) do
    %__MODULE__{
      type: characteristic_mod.type(),
      perms: characteristic_mod.perms(),
      format: characteristic_mod.format(),
      value: value
    }
  end

  @doc false
  def accessories_tree(
        %__MODULE__{type: type, perms: perms, format: format} = characteristic,
        service_index,
        characteristic_index,
        opts \\ []
      ) do
    iid = HAP.IID.to_iid(service_index, characteristic_index)

    cond do
      Keyword.get(opts, :static_only) -> %{iid: iid, type: type}
      "pr" in perms -> %{iid: iid, type: type, perms: perms, format: format, value: get_value(characteristic)}
      true -> %{iid: iid, type: type, perms: perms, format: format}
    end
  end

  @doc false
  def get_value(%__MODULE__{value: {mod, opts}}) do
    mod.get_value(opts)
  end

  @doc false
  def get_value(%__MODULE__{value: value}) do
    value
  end

  @doc false
  def put_value(%__MODULE__{value: {mod, opts}}, value) do
    mod.put_value(value, opts)
  end
end
