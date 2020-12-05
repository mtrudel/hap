defmodule HAP.AccessoryServer do
  @moduledoc """
  Represents a top-level HAP instance configuration
  """

  alias HAP.{Accessory, Characteristic, ConsoleDisplay, Crypto.SHA512}

  defstruct port: nil,
            display_module: nil,
            data_path: nil,
            name: nil,
            model: nil,
            identifier: nil,
            pairing_code: nil,
            setup_id: nil,
            accessory_type: nil,
            accessories: nil

  @typedoc """
  Represents an accessory server consisting of a number of accessories
  """
  @type t :: %__MODULE__{
          port: :inet.port_number(),
          display_module: module(),
          data_path: String.t(),
          name: name(),
          model: model(),
          identifier: accessory_identifier(),
          pairing_code: pairing_code(),
          setup_id: setup_id(),
          accessory_type: accessory_type(),
          accessories: [HAP.Accessory.t()]
        }

  @typedoc """
  The name of an accessory server
  """
  @type name :: String.t()

  @typedoc """
  The model of an accessory server
  """
  @type model :: String.t()

  @typedoc """
  A unique identifier string in the form "AA:BB:CC:DD:EE:FF"
  """
  @type accessory_identifier :: String.t()

  @typedoc """
  A pairing code of the form 123-45-678
  """
  @type pairing_code :: String.t()

  @typedoc """
  A pairing URL suitable for display in a QR code
  """
  @type pairing_url :: String.t()

  @typep setup_id :: String.t()

  @typedoc """
  A HAP specified value indicating the primary function of this device as found 
  in Section 13 of Apple's [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/). 
  Valid values include:
    1. Other
    2. Bridge
    3. Fan
    4. Garage
    5. Lightbulb
    6. Door Lock
    7. Outlet
    8. Switch
    9. Thermostat
    10. Sensor
    11. Security System
    12. Door
    13. Window
    14. Window Covering
    15. Programmable Switch
    16. Range Extender
    17. IP Camera
    18. Video Door Bell
    19. Air Purifier
    20. Heater
    21. Air Conditioner
    22. Humidifier
    23. Dehumidifier
    28. Sprinkler
    29. Faucet
    30. Shower System
    32. Remote
  """
  @type accessory_type :: integer()

  @doc """
  Generates the pairing url to be used to pair with this accessory server. This 
  URL can be encoded in a QR code to enable pairing directly from an iOS device
  """
  @spec pairing_url(t()) :: String.t()
  def pairing_url(%__MODULE__{} = accessory) do
    padding = 0
    version = 0
    reserved = 0
    accessory_type = accessory.accessory_type
    hap_type = 2
    pairing_code_int = accessory.pairing_code |> String.replace("-", "") |> String.to_integer()

    payload =
      <<padding::2, version::3, reserved::4, accessory_type::8, hap_type::4, pairing_code_int::27>>
      |> :binary.decode_unsigned()
      |> Base36.encode()

    "X-HM://00#{payload}#{accessory.setup_id}"
  end

  @doc false
  def build_accessory_server(accessory_server) do
    %__MODULE__{
      port: Keyword.get(accessory_server, :port, 0),
      display_module: Keyword.get(accessory_server, :display_module, ConsoleDisplay),
      data_path: Keyword.get(accessory_server, :data_path, "hap_data"),
      name: Keyword.get(accessory_server, :name, "Generic HAP Device"),
      model: Keyword.get(accessory_server, :model, "Generic HAP Model"),
      identifier: Keyword.get(accessory_server, :identifier),
      pairing_code: Keyword.get(accessory_server, :pairing_code, random_pairing_code()),
      setup_id: Keyword.get(accessory_server, :setup_id, random_setup_id()),
      accessory_type: Keyword.get(accessory_server, :accessory_type, 1),
      accessories: Keyword.get(accessory_server, :accessories, [])
    }
  end

  @doc false
  def config_hash(%__MODULE__{} = accessory_server) do
    accessory_server
    |> accessories_tree(static_only: true)
    |> Jason.encode!()
    |> SHA512.hash()
  end

  @doc false
  def accessories_tree(%__MODULE__{accessories: accessories}, opts \\ []) do
    formatted_accessories =
      accessories
      |> Enum.with_index(1)
      |> Enum.map(fn {accessory, aid} ->
        Accessory.accessories_tree(accessory, aid, opts)
      end)

    %{accessories: formatted_accessories}
  end

  @doc false
  def get_characteristics(%__MODULE__{accessories: accessories}, characteristics) do
    formatted_characteristics =
      characteristics
      |> Enum.map(fn %{aid: aid, iid: iid} ->
        value =
          accessories
          |> Enum.at(aid - 1)
          |> Accessory.get_characteristic(iid)
          |> Characteristic.get_value()

        %{aid: aid, iid: iid, value: value}
      end)

    %{characteristics: formatted_characteristics}
  end

  @doc false
  def put_characteristics(%__MODULE__{accessories: accessories}, characteristics) do
    characteristics
    |> Enum.map(fn
      %{"aid" => aid, "iid" => iid, "value" => value} = characteristic ->
        result =
          accessories
          |> Enum.at(aid - 1)
          |> Accessory.get_characteristic(iid)
          |> Characteristic.put_value(value)

        {result, characteristic}

      %{"aid" => _aid, "iid" => _iid, "ev" => _} = characteristic ->
        # TODO -- event registration should be handled somewhere w/ state
        {:ok, characteristic}
    end)
  end

  defp random_pairing_code do
    "#{random_digits(3)}-#{random_digits(2)}-#{random_digits(3)}"
  end

  defp random_setup_id do
    Stream.repeatedly(fn -> <<Enum.random(?A..?Z)>> end) |> Enum.take(4) |> Enum.join()
  end

  defp random_digits(number) do
    Stream.repeatedly(&random_digit/0) |> Enum.take(number) |> Enum.join()
  end

  defp random_digit do
    Enum.random(0..9)
  end
end
