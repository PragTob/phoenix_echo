defmodule PhoenixEcho.ChannelsTest do
  use PhoenixEcho.ChannelCase
  alias Phoenix.Integration.WebsocketClient

  describe "connecting to the socket" do
    test "clients can connect" do
      assert {:ok, _socket} = WebsocketClient.start_link(self, "ws://localhost:4001/socket/websocket")
    end

    test "clients can be denied connection" do
      assert {:error, _} = WebsocketClient.start_link(self, "ws://localhost:4001/socket/websocket?connect=false")
    end
  end
end
