defmodule HAP.Accessory do
  @moduledoc """
  Represents a single accessory object, containing a number of services
  """

  alias HAP.{IID, Service, Services}

  defstruct services: []

  def build_accessory(accessory) do
    {[services: services], metadata} = Keyword.split(accessory, [:services])

    %__MODULE__{
      services:
        [Services.AccessoryInformation.build_service(metadata), Services.ProtocolInformation.build_service()] ++
          services
    }
  end

  def accessories_tree(%__MODULE__{services: services}, aid, opts \\ []) do
    formatted_services =
      services
      |> Enum.with_index()
      |> Enum.map(fn {service, service_index} ->
        Service.accessories_tree(service, service_index, opts)
      end)

    %{aid: aid, services: formatted_services}
  end

  def get_characteristic(%__MODULE__{services: services}, iid) do
    services
    |> Enum.at(IID.service_index(iid))
    |> Service.get_characteristic(iid)
  end
end
