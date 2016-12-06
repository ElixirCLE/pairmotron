defmodule Pairmotron.SessionController do
  use Pairmotron.Web, :controller

  alias Pairmotron.User

  plug :scrub_params, "user" when action in [:create]

  def new(conn, _params) do
    render conn, changeset: User.changeset(%User{})
  end

  def create(conn, %{"user" => user_params}) do
    if is_nil(user_params["email"]) do
      nil
    else
      Repo.get_by(User, email: user_params["email"])
    end
    |> sign_in(user_params["password"], conn)
  end

  def delete(conn, _) do
    delete_session(conn, :current_user_id)
    |> put_flash(:info, "You have been logged out")
    |> redirect(to: session_path(conn, :new))
  end

  @sign_in_error "Name and/or password are incorrect."

  defp sign_in(user, password, conn) when is_nil(user) or is_nil(password) do
    conn
    |> put_flash(:error, @sign_in_error)
    |> render("new.html", changeset: User.changeset(%User{}))
  end

  defp sign_in(user, password, conn) when is_map(user) do
    if Comeonin.Bcrypt.checkpw(password, user.password_hash) do
      conn
      |> put_session(:current_user_id, user.id)
      |> put_flash(:info, "You are now signed in.")
      |> redirect(to: page_path(conn, :index))
    else
      conn
      |> put_flash(:error, @sign_in_error)
      |> render("new.html", changeset: User.changeset(%User{}))
    end
  end
end
