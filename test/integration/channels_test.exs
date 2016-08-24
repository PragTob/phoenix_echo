defmodule PhoenixEcho.ChannelsTest do
  use PhoenixEcho.ChannelCase
  alias Phoenix.Integration.WebsocketClient

  test "clients can join" do
    assert {:ok, _socket} = WebsocketClient.start_link(self, "ws://localhost:4001/socket/websocket")
  end
end
