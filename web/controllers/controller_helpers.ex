defmodule Pairmotron.ControllerHelpers do
  @moduledoc """
  Contains functions that are useful for Pairmotron Controllers. These
  functions are not currently globally imported and have to be imported
  individually to the controllers that need them
  """

  import Plug.Conn
  import Phoenix.Controller

  @doc """
  Renders a 404 message.

  Used by canary whenever load_and_authorize_resource receives an id that
  does not correspond to an object in the database.
  """
  @spec handle_resource_not_found(%Plug.Conn{}) :: %Plug.Conn{}
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
  @spec redirect_not_authorized(%Plug.Conn{}, binary()) :: %Plug.Conn{}
  def redirect_not_authorized(conn, path) do
    conn
    |> put_flash(:error, "You do not have access to that!")
    |> redirect(to: path)
  end

  @doc """
  Given a field, and params passed to :create or :update actions, this looks
  for the field specified and returns it as an integer if possible. If not
  possible, it returns 0. This is intended to be used on association IDs so
  that they can easily be retrieved from Ecto if necessary.
  """
  @spec parameter_as_integer(map(), binary()) :: integer()
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
  @spec is_admin?(Types.user) :: boolean()
  def is_admin?(user) do
    user.is_admin
  end
end
