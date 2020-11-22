defmodule HAP.AccessoryServer do
  @moduledoc """
  Represents a top-level HAP instance configuration
  """

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

  def build_accessory_server(accessory_server) do
    %__MODULE__{
      port: Keyword.get(accessory_server, :port, 0),
      display_module: Keyword.get(accessory_server, :display_module, HAP.ConsoleDisplay),
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

  def config_hash(%__MODULE__{} = accessory_server) do
    accessory_server
    |> accessories_tree(static_only: true)
    |> Jason.encode!()
    |> HAP.Crypto.SHA512.hash()
  end

  def accessories_tree(%__MODULE__{accessories: accessories}, opts \\ []) do
    formatted_accessories =
      accessories
      |> Enum.with_index(1)
      |> Enum.map(fn {accessory, aid} ->
        HAP.Accessory.accessories_tree(accessory, aid, opts)
      end)

    %{accessories: formatted_accessories}
  end

  def get_characteristics(%__MODULE__{accessories: accessories}, characteristics) do
    formatted_characteristics =
      characteristics
      |> Enum.map(fn %{aid: aid, iid: iid} ->
        value =
          accessories
          |> Enum.at(aid - 1)
          |> HAP.Accessory.get_characteristic(iid)
          |> HAP.Characteristic.get_value()

        %{aid: aid, iid: iid, value: value}
      end)

    %{characteristics: formatted_characteristics}
  end

  def put_characteristics(%__MODULE__{accessories: accessories}, characteristics) do
    characteristics
    |> Enum.map(fn
      %{"aid" => aid, "iid" => iid, "value" => value} = characteristic ->
        result =
          accessories
          |> Enum.at(aid - 1)
          |> HAP.Accessory.get_characteristic(iid)
          |> HAP.Characteristic.put_value(value)

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
