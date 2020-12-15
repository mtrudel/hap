defmodule HAP.AccessoryServer do
  @moduledoc """
  Represents a top-level HAP instance configuration
  """

  defstruct display_module: nil,
            data_path: nil,
            name: nil,
            model: nil,
            identifier: nil,
            pairing_code: nil,
            setup_id: nil,
            accessory_type: nil,
            accessories: []

  @typedoc """
  Represents an accessory server consisting of a number of accessories. Contains the following fields:

  * `name`: The name to assign to this device, for example 'HAP Bridge'
  * `model`: The model name to assign to this device, for example 'HAP Co. Super Bridge III'
  * `identifier`: A unique identifier string in the form "AA:BB:CC:DD:EE:FF"
  * `pairing_code`: A pairing code of the form 123-45-678 to be used for pairing. 
  If not specified one will be defined dynamically.
  * `setup_id`: A 4 character string used as part of the accessory discovery process. 
  If not specified one will be defined dynamically.
  * `display_module`: An optional implementation of `HAP.Display` used to present pairing 
  and other information to the user. If not specified then a basic console-based
  display is used.
  * `data_path`: The path to where HAP will store its internal data. Will be created if
  it does not exist. If not specified, `hap_data` is used.
  * `accessory_type`: A HAP specified value indicating the primary function of this 
  device. See `t:HAP.AccessoryServer.accessory_type/0` for details
  * `accessories`: A list of `HAP.Accessory` structs to include in this accessory server
  """
  @type t :: %__MODULE__{
          name: name(),
          model: model(),
          identifier: accessory_identifier(),
          pairing_code: pairing_code(),
          setup_id: setup_id(),
          display_module: module(),
          data_path: String.t(),
          accessory_type: accessory_type(),
          accessories: [HAP.Accessory.t()]
        }

  @typedoc """
  The name to advertise for this accessory server, for example 'HAP Bridge'
  """
  @type name :: String.t()

  @typedoc """
  The model of this accessory server, for example 'HAP Co. Super Bridge III'
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

  @typedoc """
  A 4 character string used as part of the accessory discovery process
  """
  @type setup_id :: String.t()

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
  def compile(%__MODULE__{} = accessory_server) do
    accessory_server
    |> Map.update!(:display_module, &(&1 || HAP.ConsoleDisplay))
    |> Map.update!(:data_path, &(&1 || "hap_data"))
    |> Map.update!(:name, &(&1 || "Generic HAP Device"))
    |> Map.update!(:model, &(&1 || "Generic HAP Model"))
    |> Map.update!(:pairing_code, &(&1 || random_pairing_code()))
    |> Map.update!(:setup_id, &(&1 || random_setup_id()))
    |> Map.update!(:accessory_type, &(&1 || 1))
    |> Map.update!(:accessories, fn accessories ->
      accessories |> Enum.map(&HAP.Accessory.compile/1)
    end)
  end

  @doc false
  def config_hash(%__MODULE__{} = accessory_server) do
    accessory_server
    |> accessories_tree(false)
    |> Jason.encode!()
    |> HAP.Crypto.SHA512.hash()
  end

  @doc false
  def accessories_tree(%__MODULE__{accessories: accessories}, include_values \\ true) do
    %{
      accessories:
        accessories
        |> Enum.with_index(1)
        |> Enum.map(fn {%HAP.Accessory{services: services}, aid} ->
          %{
            aid: aid,
            services:
              services
              |> Enum.with_index()
              |> Enum.map(fn {%HAP.Service{type: type, characteristics: characteristics}, service_index} ->
                %{
                  iid: HAP.IID.to_iid(service_index),
                  type: type,
                  characteristics:
                    characteristics
                    |> Enum.with_index()
                    |> Enum.map(fn {characteristic, characteristic_index} ->
                      result = %{
                        iid: HAP.IID.to_iid(service_index, characteristic_index),
                        type: HAP.Characteristic.get_type(characteristic),
                        perms: HAP.Characteristic.get_perms(characteristic),
                        format: HAP.Characteristic.get_format(characteristic)
                      }

                      if "pr" in HAP.Characteristic.get_perms(characteristic) && include_values do
                        result |> Map.put(:value, HAP.Characteristic.get_value!(characteristic))
                      else
                        result
                      end
                    end)
                }
              end)
          }
        end)
    }
  end

  @doc false
  def get_characteristics(%__MODULE__{} = accessory_server, characteristics) do
    characteristics
    |> Enum.map(fn %{aid: aid, iid: iid} ->
      with {:ok, accessory} <- get_accessory(accessory_server, aid),
           {:ok, service} <- HAP.Accessory.get_service(accessory, iid),
           {:ok, characteristic} <- HAP.Service.get_characteristic(service, iid),
           {:ok, value} <- HAP.Characteristic.get_value(characteristic) do
        %{aid: aid, iid: iid, value: value, status: 0}
      else
        {:error, reason} -> %{aid: aid, iid: iid, status: reason}
      end
    end)
  end

  @doc false
  def put_characteristics(%__MODULE__{} = accessory_server, characteristics) do
    characteristics
    |> Enum.map(fn
      %{"aid" => aid, "iid" => iid, "value" => value} ->
        with {:ok, accessory} <- get_accessory(accessory_server, aid),
             {:ok, service} <- HAP.Accessory.get_service(accessory, iid),
             {:ok, characteristic} <- HAP.Service.get_characteristic(service, iid),
             :ok <- HAP.Characteristic.put_value(characteristic, value) do
          %{aid: aid, iid: iid, status: 0}
        else
          {:error, reason} -> %{aid: aid, iid: iid, status: reason}
        end

      %{"aid" => aid, "iid" => iid, "ev" => _} ->
        # TODO -- event registration should be handled somewhere w/ state
        %{aid: aid, iid: iid, status: 0}
    end)
  end

  defp get_accessory(%__MODULE__{accessories: accessories}, aid) do
    case Enum.at(accessories, aid - 1) do
      nil -> {:error, -70_409}
      accessory -> {:ok, accessory}
    end
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
