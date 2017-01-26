defmodule PhoenixEcho.ChannelsTest do
  use PhoenixEcho.ChannelCase
  alias Phoenix.Integration.WebsocketClient
  alias Phoenix.Socket.Message

  import ExUnit.CaptureLog

  @topic "echo:hello"
  @payload %{}
  @socket_url "ws://localhost:4001/socket/websocket"
  describe "connecting to the socket" do
    test "clients can connect" do
      assert {:ok, _socket} = socket_connect()
    end

    test "clients can be denied connection" do
      assert {:error, _} = socket_connect "#{@socket_url}?connect=false"
    end
  end

  describe "joining channels" do
    test "successfully joins channel" do
      {:ok, socket} = socket_connect()
      join_topic(socket, @topic, %{})
      assert_joined @topic
    end

    test "unauthorized join request" do
      {:ok, socket} = socket_connect()
      join_topic(socket, @topic, %{"authorized" => false})
      assert_receive %Message{
        event: "phx_reply",
        payload: %{
          "status" => "error",
          "response" => %{
            "reason" => "unauthorized"
          }
        },
        topic: @topic,
        ref: "1"
      }
    end

    test "joining an non existed channel" do
      capture_log fn ->
        {:ok, socket} = socket_connect()
        join_topic(socket, "foo:bar")
        assert_receive %Message{
          event: "phx_reply",
          payload: %{
            "status" => "error"
          },
          ref: "1"
        }
      end
    end
  end

  describe "sending events happy path" do
    test "it echoes them back on echo" do
      socket = join(@topic)
      payload = %{"foo" => "bar"}
      send_event(socket, "echo:hello", "echo", payload)
      assert_receive %Message{
        event: "phx_reply",
        payload: %{"response" => ^payload}
      }
    end

    test "echos back non JSON/map inputs" do
      socket = join @topic

      send_event socket, @topic, "echo", "fooo"
      assert_receive %Message{
        event: "phx_reply",
        payload: %{"response" => %{"payload" => "fooo"}}}
    end

    test "it might not reply" do
      socket = join(@topic)
      send_event(socket, @topic, "no_reply")

      refute_receive %Message{}
    end

    test "it might broadcast as a result" do
      socket = join(@topic)
      send_event(socket, @topic, "shout", %{"answer" => 42})

      assert_receive %Message{
        event:   "shout",
        payload: %{"answer" => 42},
        topic:   "echo:hello"
      }
    end

    test "it might broadcast_from as a result (sender doesn't get broadcast message)" do
      socket = join(@topic)
      send_event(socket, @topic, "shout_with_earplugs", %{"answer" => 42})

      refute_receive %Message{}
    end

    test "it could push messages as well as reply" do
      socket = join(@topic)
      payload = %{"answer" => 42}
      send_event(socket, @topic, "push", payload)

      assert_receive %Message{
        event:  "phx_reply",
        payload: %{"response" => ^payload}
      }
      assert_receive %Message{
        event:  "answer",
        payload: ^payload
      }
    end
  end

  describe "sending events error cases" do
    test "can't match an event" do
      socket = join(@topic)

      capture_log fn ->
        send_event(socket, @topic, "nonexistant", %{"answer" => 42})
        assert_receive %Message{event: "phx_error"}
      end
    end

    test "send message and then boom" do
      socket = join @topic

      send_event socket, @topic, "echo"
      assert_receive %Message{event: "phx_reply", ref: "2"}

      send_event socket, @topic, "echo"
      assert_receive %Message{event: "phx_reply", ref: "3"}

      capture_log fn ->
        send_event socket, @topic, "boom"
        assert_receive %Message{event: "phx_error", ref: "1"}
      end
    end

    test "channel crashes" do
      socket = join @topic

      capture_log fn ->
        send_event socket, @topic, "boom"
        assert_receive %Message{event: "phx_error"}
      end
    end

    test "channel takes a long time to answer" do
      socket = join @topic

      sleep_ms = 200
      send_event socket, @topic, "sleep", %{"time" => sleep_ms}
      refute_receive %Message{}, sleep_ms
      assert_receive %Message{event: "phx_reply"}
    end
  end

  describe "shutting down the channel" do
    test "stop normal" do
      socket = join @topic

      send_event socket, @topic, "stop_normal"
      assert_receive %Message{event: "phx_close"}
    end

    test "stop shutdown" do
      socket = join @topic

      send_event socket, @topic, "stop_shutdown"
      assert_receive %Message{event: "phx_close"}
    end

    test "stop any leads to an error" do
      socket = join @topic

      capture_log fn ->
        send_event socket, @topic, "stop_any"
        assert_receive %Message{event: "phx_error"}
      end
    end
  end

  defp socket_connect(url \\ @socket_url) do
    WebsocketClient.start_link(self(), url)
  end

  defp join_topic(socket, topic, payload \\ @payload) do
    WebsocketClient.join(socket, topic, payload)
  end

  defp join(topic, payload \\ @payload) do
    {:ok, socket} = socket_connect @socket_url
    join_topic(socket, topic, payload)
    assert_joined topic
    socket
  end

  defp send_event(socket, topic, event, payload \\ @payload) do
    WebsocketClient.send_event(socket, topic, event, payload)
  end

  defp assert_joined(expected_topic) do
    assert_receive %Message{event: "phx_reply",
                            payload: %{"response" => %{}, "status" => "ok"},
                            topic: ^expected_topic }
  end
end
