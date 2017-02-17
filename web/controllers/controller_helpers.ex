defmodule Pairmotron.ControllerHelpers do

  import Plug.Conn
  import Phoenix.Controller
  alias Pairmotron.{Repo, PairRetro}

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

  @doc """
  Given a field, and params passed to :create or :update actions,
  this looks for the field specified and returns it as an integer
  if possible. If not possible, it returns 0. This is intended
  to be used on association IDs so that they can easily be retrieved
  from Ecto if necessary. The field argument should be a binary.
  """
  def parameter_as_integer(params, field) do
    case Map.get(params, field, 0) do
      id when is_binary(id) ->
        case Integer.parse(id) do
          {int, _} -> int
          _ -> 0
        end
      id when is_integer(id) -> id
      _ -> 0
    end
  end

  @doc """
  Given a user, returns true if that user has a role and that role's
  is_admin property is true. Otherwise, returns false.
  """
  def is_admin?(user) do
    user.is_admin
  end

  @doc """
  Assigns a retro to the current user for a given year and week
  """
  def assign_current_user_pair_retro_for_week(conn, year, week) do
    current_user = conn.assigns[:current_user]
    retro = Repo.one(PairRetro.retro_for_user_and_week(current_user, year, week))
    Plug.Conn.assign(conn, :current_user_retro_for_week, retro)
  end
end
