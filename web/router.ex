defmodule PhoenixEcho.Router do
  use PhoenixEcho.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", PhoenixEcho do
    pipe_through :api
  end
end
