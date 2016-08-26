defmodule PhoenixEcho.Mixfile do
  use Mix.Project

  def project do
    [app: :phoenix_echo,
     version: "0.0.1",
     elixir: "~> 1.3",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {PhoenixEcho, []},
     applications: [:phoenix, :phoenix_pubsub, :cowboy, :logger]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.2.1"},
     {:phoenix_pubsub, "~> 1.0"},
     {:cowboy, "~> 1.0"},
     {:ex_guard, "~> 1.1.1", only: :dev},
     {:websocket_client, git: "https://github.com/jeremyong/websocket_client.git", only: [:test, :dev]}]
  end
end
