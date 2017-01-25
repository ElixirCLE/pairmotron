defmodule Pairmotron.RequireAdmin do
  import Plug.Conn

  alias Pairmotron.Router.Helpers, as: Routes
  alias Pairmotron.Plug.Authenticate, as: Auth

  def init(opts), do: opts

  def call(conn, _opts) do
    current_user = Auth.current_user(conn)
    require_admin(current_user, conn)
  end

  def require_admin(%{is_admin: true}, conn), do: conn
  def require_admin(_, conn) do
    conn
    |> Phoenix.Controller.redirect(to: Routes.page_path(conn, :index))
    |> halt
  end
end
