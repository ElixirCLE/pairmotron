defmodule Pairmotron.Plug.RequireAuthentication do
  alias Pairmotron.Router.Helpers, as: Routes
  import Plug.Conn

  alias Pairmotron.User

  @spec init(keyword()) :: keyword()
  def init(opts) do
    opts
  end

  @spec call(%Plug.Conn{}, keyword()) :: %Plug.Conn{}
  def call(conn, _opts) do
    assign_current_user(conn)
  end

  @spec assign_current_user(%Plug.Conn{}) :: %Plug.Conn{}
  defp assign_current_user(conn = %Plug.Conn{}) do
    current_user = conn.assigns[:current_user] || Guardian.Plug.current_resource(conn)
    assign_current_user(conn, current_user)
  end

  @spec assign_current_user(%Plug.Conn{}, any()) :: %Plug.Conn{}
  defp assign_current_user(conn, user = %User{}) do
    assign(conn, :current_user, user)
  end
  defp assign_current_user(conn, _), do: redirect_to_sign_in(conn)

  @spec redirect_to_sign_in(%Plug.Conn{}) :: %Plug.Conn{}
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
