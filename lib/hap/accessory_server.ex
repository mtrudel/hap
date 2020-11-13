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
            accessory_objects: []

  def accessories_tree(%__MODULE__{accessory_objects: accessory_objects}) do
    formatted_accessories =
      accessory_objects
      |> Enum.with_index(1)
      |> Enum.map(fn {accessory_object, aid} ->
        HAP.AccessoryObject.accessories_tree(accessory_object, aid)
      end)

    %{accessories: formatted_accessories}
  end

  def get_characteristics(%__MODULE__{accessory_objects: accessory_objects}, characteristics) do
    formatted_characteristics =
      characteristics
      |> Enum.map(fn %{aid: aid, iid: iid} ->
        value =
          accessory_objects
          |> Enum.at(aid - 1)
          |> HAP.AccessoryObject.get_characteristic(iid)
          |> HAP.Characteristic.get_value()

        %{aid: aid, iid: iid, value: value}
      end)

    %{characteristics: formatted_characteristics}
  end

  def put_characteristics(%__MODULE__{accessory_objects: accessory_objects}, characteristics) do
    characteristics
    |> Enum.map(fn
      %{"aid" => aid, "iid" => iid, "value" => value} = characteristic ->
        result =
          accessory_objects
          |> Enum.at(aid - 1)
          |> HAP.AccessoryObject.get_characteristic(iid)
          |> HAP.Characteristic.put_value(value)

        {result, characteristic}

      %{"aid" => _aid, "iid" => _iid, "ev" => true} = characteristic ->
        # TODO -- event registration should be handled somewhere w/ state
        {:ok, characteristic}
    end)
  end
end
