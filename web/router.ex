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
    admin_routes()
  end

  scope "/admin_test", Pairmotron do
    pipe_through [:browser, :authenticate, :admin]
    resources "/users", AdminUserController
    resources "/groups", AdminGroupController
    resources "/projects", AdminProjectController
  end

  scope "/", Pairmotron do
    pipe_through [:browser, :authenticate]

    get "/profile", ProfileController, :show
    get "/profile/edit", ProfileController, :edit
    put "/profile/update/:id", ProfileController, :update
    resources "/projects", ProjectController

    get "/pairs", PairController, :index
    get "/pairs/:year/:week", PairController, :show

    get "/groups/:id/pairs", GroupPairController, :show
    get "/groups/:id/pairs/:year/:week", GroupPairController, :show
    delete "/groups/:id/pairs/:year/:week", GroupPairController, :delete
    resources "/groups/:group_id/invitations", GroupInvitationController, only: [:index, :new, :create, :update, :delete]
    resources "/invitations", UsersGroupMembershipRequestController, only: [:index, :create, :update, :delete]
    resources "/groups", GroupController
    delete "/groups/:group_id/users/:user_id", UserGroupController, :delete
    get "/groups/:group_id/users/:user_id", UserGroupController, :edit
    put "/groups/:group_id/users/:user_id", UserGroupController, :update

    get "/pair_retros/new/:pair_id", PairRetroController, :new
    resources "/pair_retros", PairRetroController, except: [:new]
  end

end
