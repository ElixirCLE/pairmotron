defmodule Pairmotron.Router do
  use Pairmotron.Web, :router
  use ExAdmin.Router

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
    plug Pairmotron.Plug.RequireAuthentication
  end

  pipeline :admin do
    plug Pairmotron.Plug.RequireAdmin
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
    delete "/logout", SessionController, :delete # Exadmin logout needs this
  end

  scope "/admin", ExAdmin do
    pipe_through [:browser, :authenticate, :admin]
    admin_routes
  end

  scope "/", Pairmotron do
    pipe_through [:browser, :authenticate] # Use the default browser stack

    get "/pairs", PageController, :index
    get "/profile", ProfileController, :show
    get "/profile/edit", ProfileController, :edit
    put "profile/update/:id", ProfileController, :update
    resources "/users", UserController
    resources "/projects", ProjectController
    resources "/groups", GroupController

    get "/pair_retros/new/:pair_id", PairRetroController, :new
    resources "/pair_retros", PairRetroController, except: [:new]

    get "/:year/:week", PageController, :show
    delete "/:year/:week", PageController, :delete
  end

end
