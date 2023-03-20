defmodule HAP.CleartextHTTPServer do
  @moduledoc false
  # Defines the HTTP interface for a HomeKit Accessory which may only be accessed over
  # a non-encrpyted channel

  use Plug.Router

  plug(:match)
  plug(:prohibit_authenticated_session)
  plug(:dispatch)

  def init(opts) do
    opts
  end

  post "/identify" do
    if HAP.AccessoryServerManager.paired?() do
      conn
      |> send_resp(400, "Already Paired")
    else
      HAP.AccessoryServerManager.name() |> HAP.Display.identify()

      conn
      |> send_resp(204, "No Content")
    end
  end

  post "/pair-setup" do
    conn.body_params
    |> HAP.PairSetup.handle_message()
    |> case do
      {:ok, response} ->
        conn
        |> put_resp_header("content-type", "application/pairing+tlv8")
        |> send_resp(200, HAP.TLVEncoder.to_binary(response))

      {:error, reason} ->
        conn
        |> send_resp(400, reason)
    end
  end

  post "/pair-verify" do
    pair_state = HAP.HAPSessionTransport.get_pair_state()

    HAP.PairVerify.handle_message(conn.body_params, pair_state)
    |> case do
      {:ok, response, new_state, accessory_to_controller_key, controller_to_accessory_key} ->
        conn =
          conn
          |> put_resp_header("content-type", "application/pairing+tlv8")
          |> send_resp(200, HAP.TLVEncoder.to_binary(response))

        HAP.HAPSessionTransport.put_pair_state(new_state)
        HAP.HAPSessionTransport.put_send_key(accessory_to_controller_key)
        HAP.HAPSessionTransport.put_recv_key(controller_to_accessory_key)

        conn

      {:error, reason} ->
        conn
        |> send_resp(400, reason)
    end
  end

  defp prohibit_authenticated_session(conn, _opts) do
    if HAP.HAPSessionTransport.encrypted_session?() do
      conn
      |> send_resp(401, "Not Authorized")
      |> halt()
    else
      conn
    end
  end
end
