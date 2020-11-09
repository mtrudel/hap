defmodule HAP.Pairings do
  @moduledoc """
  Implements the Add / Remove / List Pairings flows described in Apple's [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/). 
  """

  require Logger

  alias HAP.Configuration

  @kTLVType_Method 0x00
  @kTLVType_Identifier 0x01
  @kTLVType_PublicKey 0x03
  @kTLVType_State 0x06
  @kTLVType_Error 0x07
  @kTLVType_Permissions 0x0B
  @kTLVType_Separator 0xFF

  @kTLVError_Unknown <<0x01>>
  @kTLVError_Authentication <<0x02>>

  @kMethod_AddPairing <<0x03>>
  @kMethod_RemovePairing <<0x04>>
  @kMethod_ListPairings <<0x05>>

  # Handles Add Pairing `<M1>` messages and returns `<M2>` messages
  def handle_message(
        %{
          @kTLVType_State => <<1>>,
          @kTLVType_Method => @kMethod_AddPairing,
          @kTLVType_Identifier => additional_ios_identifier,
          @kTLVType_PublicKey => additional_ios_ltpk,
          @kTLVType_Permissions => additional_ios_permissions
        },
        %{admin?: true}
      ) do
    case Configuration.get_controller_pairing(additional_ios_identifier) do
      nil ->
        Configuration.add_controller_pairing(additional_ios_identifier, additional_ios_ltpk, additional_ios_permissions)
        {:ok, %{@kTLVType_State => <<2>>}}

      {^additional_ios_ltpk, _existing_ios_permissions} ->
        Configuration.add_controller_pairing(additional_ios_identifier, additional_ios_ltpk, additional_ios_permissions)
        {:ok, %{@kTLVType_State => <<2>>}}

      _ ->
        {:ok, %{@kTLVType_State => <<2>>, @kTLVType_Error => @kTLVError_Unknown}}
    end
  end

  # Handles Remove Pairing `<M1>` messages and returns `<M2>` messages
  # TODO - this should tear down its own session
  def handle_message(
        %{
          @kTLVType_State => <<1>>,
          @kTLVType_Method => @kMethod_RemovePairing,
          @kTLVType_Identifier => removed_ios_identifier
        },
        %{admin?: true}
      ) do
    Configuration.remove_controller_pairing(removed_ios_identifier)
    {:ok, %{@kTLVType_State => <<2>>}}
  end

  # Handles List Pairings `<M1>` messages and returns `<M2>` messages
  def handle_message(%{@kTLVType_State => <<1>>, @kTLVType_Method => @kMethod_ListPairings}, %{admin?: true}) do
    response =
      Configuration.get_controller_pairings()
      |> Enum.map_intersperse({@kTLVType_Separator, <<>>}, fn {ios_identifer, {ios_ltpk, ios_permissions}} ->
        [
          {@kTLVType_Identifier, ios_identifer},
          {@kTLVType_PublicKey, ios_ltpk},
          {@kTLVType_Permissions, ios_permissions}
        ]
      end)
      |> Enum.flat_map(& &1)

    {:ok, Enum.concat([{@kTLVType_State, <<2>>}], response)}
  end

  def handle_message(%{@kTLVType_State => <<1>>}, %{admin?: false}) do
    response = %{@kTLVType_State => <<2>>, @kTLVType_Error => @kTLVError_Authentication}
    {:ok, response}
  end

  def handle_message(tlv, state) do
    Logger.error("Received unexpected message for pairing state. Message: #{inspect(tlv)}, state: #{inspect(state)}")
    {:error, "Unexpected message for pairing state"}
  end
end
