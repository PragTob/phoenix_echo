defmodule PhoenixEcho.ChannelsTest do
  use PhoenixEcho.ChannelCase
  alias Phoenix.Integration.WebsocketClient

  describe "connecting to the socket" do
    test "clients can connect" do
      assert {:ok, _socket} = socket_connect
    end

    test "clients can be denied connection" do
      assert {:error, _} = socket_connect "ws://localhost:4001/socket/websocket?connect=false"
    end
  end

  defp socket_connect(url \\ "ws://localhost:4001/socket/websocket") do
    WebsocketClient.start_link(self, url)
  end
end
