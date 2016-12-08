defmodule Pairmotron.Plug.Authenticate do
  alias Pairmotron.Router.Helpers, as: Routes
  import Plug.Conn

  alias Pairmotron.{Repo, User}

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    assign_current_user(conn)
  end

  defp assign_current_user(conn = %Plug.Conn{}) do
    current_user_id = current_assigned_user_id(conn) || Guardian.Plug.current_resource(conn)
    assign_current_user(conn, current_user_id)
  end
  defp assign_current_user(conn, id) when is_integer(id) do
    assign_current_user(conn, Repo.get(User, id))
  end
  defp assign_current_user(conn, user = %User{}) do
    assign(conn, :current_user, user)
  end
  defp assign_current_user(conn, _), do: redirect_to_sign_in(conn)

  defp current_assigned_user_id(conn) do
    case user = conn.assigns[:current_user] do
      %User{} -> user.id
      _ -> nil
    end
  end

  defp redirect_to_sign_in(conn) do
    conn
    |> Phoenix.Controller.put_flash(
         :error,
         'You need to be signed in to view this page'
       )
    |> Phoenix.Controller.redirect(to: Routes.session_path(conn, :new))
    |> halt
  end
end
