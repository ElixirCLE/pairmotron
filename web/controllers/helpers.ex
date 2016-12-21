defmodule Pairmotron.ControllerHelpers do

  import Plug.Conn
  import Phoenix.Controller

  @doc """
  Renders a 404 message.

  Used by canary whenever load_and_authorize_resource receives an id that
  does not correspond to an object in the database.
  """
  def handle_resource_not_found(conn) do
    conn
    |> put_status(:not_found)
    |> render(Pairmotron.ErrorView, "404.html")
    |> halt
  end

  @doc """
  Flashes an error message stating that the user is not authorized to
  view the current resource and redirects to the specified path.
  """
  def redirect_not_authorized(conn, path) do
    conn
    |> put_flash(:error, "You do not have access to that!")
    |> redirect(to: path)
  end
end
