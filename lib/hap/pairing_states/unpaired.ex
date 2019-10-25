defmodule HAP.PairingStates.Unpaired do
  defstruct username: "Pair-Setup", pairing_code: nil

  def new do
    %__MODULE__{pairing_code: generate_pairing_code()}
  end

  defp generate_pairing_code do
    Application.get_env(:hap, :pairing_code, random_pairing_code())
  end

  defp random_pairing_code do
    "#{random_digits(3)}-#{random_digits(2)}-#{random_digits(3)}"
  end

  defp random_digits(number) do
    Stream.repeatedly(&random_digit/0) |> Enum.take(number) |> Enum.join()
  end

  defp random_digit do
    Enum.random(0..9)
  end
end
