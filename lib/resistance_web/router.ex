defmodule ResistanceWeb.Router do
  use ResistanceWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ResistanceWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ResistanceWeb do
    pipe_through :browser

    live "/", HomeLive, :home
    live "/lobby", LobbyLive, :lobby
  end

end
