defimpl ExAdmin.Authentication, for: Plug.Conn do
  alias Pairmotron.Router.Helpers
  alias Pairmotron.Authentication, as: Auth
  alias Pairmotron.Types

  @spec use_authentication?(any()) :: boolean()
  def use_authentication?(_), do: true

  @spec current_user(%Plug.Conn{}) :: Types.user | nil
  def current_user(conn), do: Auth.current_user(conn)

  @spec current_user_name(%Plug.Conn{}) :: binary()
  def current_user_name(conn) do
    case Auth.current_user(conn) do
      nil -> ""
      user -> user.name
    end
  end

  @spec session_path(%Plug.Conn{}, atom()) :: binary()
  def session_path(conn, :destroy), do: Helpers.session_path(conn, :delete)
  def session_path(conn, action), do: Helpers.session_path(conn, action)
end
