defmodule Pairmotron.Plug.RequireAdmin do
  @moduledoc """
  Plug which halts the Plug.Conn and redirects to the /pairs path if the logged
  in user is not an admin.
  """
  import Plug.Conn

  alias Pairmotron.Router.Helpers, as: Routes
  alias Pairmotron.Authentication, as: Auth
  alias Pairmotron.Types

  @spec init(keyword()) :: keyword()
  def init(opts), do: opts

  @spec call(%Plug.Conn{}, keyword()) :: %Plug.Conn{}
  def call(conn, _opts) do
    current_user = Auth.current_user(conn)
    require_admin(current_user, conn)
  end

  @spec require_admin(Types.user, %Plug.Conn{}) :: %Plug.Conn{}
  defp require_admin(%{is_admin: true}, conn), do: conn
  defp require_admin(_, conn) do
    conn
    |> Phoenix.Controller.redirect(to: Routes.pair_path(conn, :index))
    |> halt
  end
end
