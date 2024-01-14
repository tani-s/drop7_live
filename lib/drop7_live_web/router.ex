defmodule Drop7LiveWeb.Router do
  use Drop7LiveWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {Drop7LiveWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :browser

    # get "/", PageController, :home
    live "/", Drop7Web.GameLive
  end

  if Application.compile_env(:drop7_live, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: Drop7LiveWeb.Telemetry
    end
  end
end
