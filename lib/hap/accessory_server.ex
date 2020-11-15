defmodule HAP.AccessoryServer do
  @moduledoc """
  Represents a top-level HAP instance configuration
  """

  defstruct port: 4000,
            name: nil,
            model: nil,
            identifier: nil,
            pairing_code: nil,
            setup_id: nil,
            accessory_type: 1,
            accessories: []

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

      %{"aid" => _aid, "iid" => _iid, "ev" => true} = characteristic ->
        # TODO -- event registration should be handled somewhere w/ state
        {:ok, characteristic}
    end)
  end
end
