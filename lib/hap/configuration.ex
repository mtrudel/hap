defmodule HAP.Configuration do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def config_number(pid \\ __MODULE__), do: GenServer.call(pid, :config_number)
  def name(pid \\ __MODULE__), do: GenServer.call(pid, :name)
  def identifier(pid \\ __MODULE__), do: GenServer.call(pid, :identifier)
  def accessory_type(pid \\ __MODULE__), do: GenServer.call(pid, :accessory_type)
  def pairing_code(pid \\ __MODULE__), do: GenServer.call(pid, :pairing_code)
  def setup_id(pid \\ __MODULE__), do: GenServer.call(pid, :setup_id)
  def ltpk(pid \\ __MODULE__), do: GenServer.call(pid, :ltpk)
  def ltsk(pid \\ __MODULE__), do: GenServer.call(pid, :ltsk)
  def paired?(pid \\ __MODULE__), do: GenServer.call(pid, :paired?)

  def get_controller_pairing(ios_identifier, pid \\ __MODULE__) do
    GenServer.call(pid, {:get_controller_pairing, ios_identifier})
  end

  def add_controller_pairing(ios_identifier, ios_ltpk, pid \\ __MODULE__) do
    GenServer.call(pid, {:add_controller_pairing, ios_identifier, ios_ltpk})
  end

  def init(initial_config) do
    {:ok, cub_pid} = CubDB.start_link("hap_data")

    # TODO - alert if any of these change from startup
    set_if_missing(cub_pid, :config_number, 1)
    set_if_missing(cub_pid, :name, initial_config[:name])

    # TODO - make this dynamic if we don't have it defined
    set_if_missing(cub_pid, :identifier, initial_config[:identifier])
    set_if_missing(cub_pid, :accessory_type, initial_config[:accessory_type])

    set_if_missing(
      cub_pid,
      :pairing_code,
      initial_config[:pairing_code] || "#{random_digits(3)}-#{random_digits(2)}-#{random_digits(3)}"
    )

    set_if_missing(
      cub_pid,
      :setup_id,
      Stream.repeatedly(fn -> <<Enum.random(?A..?Z)>> end) |> Enum.take(4) |> Enum.join()
    )

    if !CubDB.has_key?(cub_pid, :ltpk) || !CubDB.has_key?(cub_pid, :ltsk) do
      {:ok, ltpk, ltsk} = HAP.Crypto.EDDSA.key_gen()
      CubDB.put(cub_pid, :ltpk, ltpk)
      CubDB.put(cub_pid, :ltsk, ltsk)
    end

    set_if_missing(cub_pid, :pairings, %{})

    {:ok, %{cub_pid: cub_pid}}
  end

  def handle_call(param, _from, %{cub_pid: cub_pid} = state)
      when param in ~w(config_number name identifier accessory_type pairing_code setup_id ltpk ltsk)a do
    {:reply, CubDB.get(cub_pid, param), state}
  end

  def handle_call(:paired?, _from, %{cub_pid: cub_pid} = state) do
    {:reply, CubDB.get(cub_pid, :pairings) != %{}, state}
  end

  def handle_call({:get_controller_pairing, ios_identifier}, _from, %{cub_pid: cub_pid} = state) do
    {:reply, CubDB.get(cub_pid, :pairings)[ios_identifier], state}
  end

  def handle_call({:add_controller_pairing, ios_identifier, ios_ltpk}, _from, %{cub_pid: cub_pid} = state) do
    # TODO admin pairings
    HAP.Display.display_new_pairing_info(ios_identifier)
    if CubDB.get(cub_pid, :pairings) == %{}, do: HAP.Discovery.reload()
    CubDB.get_and_update(cub_pid, :pairings, &{:ok, Map.put(&1, ios_identifier, ios_ltpk)})
    {:reply, :ok, state}
  end

  def set_if_missing(cub_pid, key, value) do
    if !CubDB.has_key?(cub_pid, key) do
      CubDB.put(cub_pid, key, value)
    end
  end

  defp random_digits(number) do
    Stream.repeatedly(&random_digit/0) |> Enum.take(number) |> Enum.join()
  end

  defp random_digit do
    Enum.random(0..9)
  end
end
