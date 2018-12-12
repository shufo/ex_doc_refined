defmodule ExDocRefined.PhoenixSocket do
  use GenServer

  def init(args) do
    {:ok, args}
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  def __transports__ do
    handler = cowboy_version_adapter()

    config = [
      cowboy: handler
    ]

    callback_module = ExDocRefined.PhoenixSocket
    transport_path = :websocket
    websocket_socket = {transport_path, {callback_module, config}}

    [websocket_socket]
  end

  defp cowboy_version_adapter() do
    case Application.spec(:cowboy, :vsn) do
      [?1 | _] -> ExDocRefined.V1WebSocketHandler
      _ -> ExDocRefined.WebSocketHandler
    end
  end
end
