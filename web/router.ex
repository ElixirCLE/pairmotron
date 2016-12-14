defmodule Pairmotron.Router do
  use Pairmotron.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  pipeline :authenticate do
    plug Pairmotron.Plug.Authenticate
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.LoadResource
  end

  scope "/", Pairmotron do
    pipe_through :browser

    resources "/registration", RegistrationController, only: [:new, :create]

    get "/", SessionController, :new
    post "/login", SessionController, :create
    get "/logout", SessionController, :delete
  end

  scope "/", Pairmotron do
    pipe_through [:browser, :authenticate] # Use the default browser stack

    get "/pairs", PageController, :index
    resources "/users", UserController
    resources "/projects", ProjectController
    get "/:year/:week", PageController, :show
    delete "/:year/:week", PageController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", Pairmotron do
  #   pipe_through :api
  # end
end
