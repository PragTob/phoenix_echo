defmodule PhoenixEcho.ChannelsTest do
  use PhoenixEcho.ChannelCase
  alias Phoenix.Integration.WebsocketClient
  alias Phoenix.Socket.Message

  describe "connecting to the socket" do
    test "clients can connect" do
      assert {:ok, _socket} = socket_connect
    end

    test "clients can be denied connection" do
      assert {:error, _} = socket_connect "ws://localhost:4001/socket/websocket?connect=false"
    end
  end

  describe "joining channels" do
    test "successfully joins channel" do
      {:ok, socket} = socket_connect
      WebsocketClient.join(socket, "echo:hello", %{})
      assert_joined "echo:hello"
    end

    test "unauthorized join request" do
      {:ok, socket} = socket_connect
      WebsocketClient.join(socket, "echo:hello", %{"authorized" => false})
      assert_receive %Message{event: "phx_reply",
                              payload: %{
                                "status" => "error",
                                "response" => %{
                                  "reason" => "unauthorized"
                                }
                              },
                              topic: "echo:hello"}
    end

    test "joining an non existed channel" do
      {:ok, socket} = socket_connect
      WebsocketClient.join(socket, "foo:bar", %{})
      assert_receive %Message{
        event: "phx_reply",
        payload: %{
          "status" => "error"
        }
      }
    end
  end

  describe "sending events" do
    test "it echoes them back on echo" do
      {:ok, socket} = socket_connect
      WebsocketClient.join(socket, "echo:hello", %{})
      payload = %{"foo" => "bar"}
      WebsocketClient.send_event(socket, "echo:hello", "echo", payload)
      assert_receive %Message{
        event: "phx_reply",
        payload: %{"response" => ^payload}
      }
    end

    test "it might not reply" do
      {:ok, socket} = socket_connect
      WebsocketClient.join(socket, "echo:hello", %{})
      assert_receive %Message{event: "phx_reply"}

      WebsocketClient.send_event(socket, "echo:hello", "no_reply", %{})
      refute_receive %Message{event: "phx_reply"}
      assert :erlang.process_info(self, :messages) == {:messages, []}
    end
  end

  defp socket_connect(url \\ "ws://localhost:4001/socket/websocket") do
    WebsocketClient.start_link(self, url)
  end

  defp assert_joined(expected_topic) do
    assert_receive %Message{event: "phx_reply",
                            payload: %{"response" => %{}, "status" => "ok"},
                            topic: ^expected_topic }
  end
end
