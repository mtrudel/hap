defprotocol HAP.ServiceSource do
  @moduledoc """
  A protocol which allows for arbitrary service definitions to compile themselves into `HAP.Service` structs
  for use within HAP. This protocol allows HAP to expose pre-defined services such as `HAP.Services.Lightbulb`
  with fields reflecting the domain of the service, while allowing HAP to work internally with a service tree 
  close to taht defined in the HomeKit specification
  """

  @doc """
  Compile the given value into a `HAP.Service` struct
  """
  @spec compile(t()) :: HAP.Service.t()
  def compile(_value)
end
