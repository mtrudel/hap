defmodule HAP.Test.HTTPClient do
  @moduledoc """
  A super simple HTTP client that knows how to speak HAP encrypted sessions. Not
  even remotely generally compliant.
  """

  alias HAP.HAPSessionTransport

  def init(host, port) do
    HAPSessionTransport.connect(host, port, mode: :binary, active: false)
  end

  def get(socket, path, headers \\ []) do
    request(socket, "GET", path, "", headers)
  end

  def post(socket, path, body, headers \\ []) do
    request(socket, "POST", path, body, headers)
  end

  def request(socket, method, path, body, headers) do
    request = [
      "#{method} #{path} HTTP/1.1\r\n",
      Enum.map(headers, fn {k, v} -> "#{k}: #{v}\r\n" end),
      ["connection: keep-alive\r\n"],
      ["content-length: #{byte_size(body)}\r\n"],
      "\r\n",
      body
    ]

    HAPSessionTransport.send(socket, request)
    {:ok, result} = HAPSessionTransport.recv(socket, 0, :infinity)

    ["HTTP/1.1" <> code | lines] = result |> String.split("\r\n")

    code = code |> String.trim() |> String.to_integer()

    {headers, [_ | [body]]} =
      lines
      |> Enum.split_while(fn line -> line != "" end)

    headers =
      headers
      |> Enum.map(fn header ->
        [k, v] = header |> String.split(":")
        {k |> String.trim() |> String.to_atom(), String.trim(v)}
      end)

    {:ok, code, headers, body}
  end
end
