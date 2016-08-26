# PhoenixEcho [![Build Status](https://travis-ci.org/PragTob/phoenix_echo.svg?branch=master)](https://travis-ci.org/PragTob/phoenix_echo)

A simple phoenix app with just one channel that you can use to test your phoenix channel client. The channel has multiple different behaviours starting from just echoing messages it was send, over broadcasting, raising errors, denying access and closing connections.

The socket to connect to is `"ws://localhost:4000/socket/websocket"` and rooms that can be joind are `"echo:your_thing"`. For guidance on what events are supported and what they do you can check out the [echo_channel](https://github.com/PragTob/phoenix_echo/blob/master/web/channels/echo_channel.ex) or even better [its integration test suite](https://github.com/PragTob/phoenix_echo/blob/master/test/integration/channels_test.exs).

## Up and running

You got to have elixir 1.3+ and Erlang 18+ installed.

To start the Phoenix app:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phoenix.server`
  * Run tests via `mix test`
