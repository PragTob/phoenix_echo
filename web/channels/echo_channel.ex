defmodule PhoenixEcho.EchoChannel do
  use PhoenixEcho.Web, :channel

  def join("echo:" <> _room, payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("echo", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (echo:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def handle_in("no_reply", _payload, socket) do
    {:noreply, socket}
  end

  defp authorized?(%{"authorized" => false}) do
    false
  end
  defp authorized?(_payload) do
    true
  end
end
