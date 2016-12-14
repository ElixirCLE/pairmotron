defmodule Pairmotron.SessionController do
  use Pairmotron.Web, :controller

  alias Pairmotron.User

  plug :scrub_params, "user" when action in [:create]

  def new(conn, _params) do
    render conn, changeset: User.changeset(%User{})
  end

  def create(conn, %{"user" => %{"email" => nil}}) do
    conn |> bad_sign_in
  end

  def create(conn, %{"user" => user_params = %{"email" => email}}) do
    Repo.get_by(User, email: email)
    |> sign_in(user_params, conn)
  end

  def create(conn, _params), do: bad_sign_in(conn)

  def delete(conn, _) do
    Guardian.Plug.sign_out(conn)
    |> put_flash(:info, "You have been logged out")
    |> redirect(to: session_path(conn, :new))
  end

  @sign_in_error "Name and/or password are incorrect."

  defp bad_sign_in(conn) do
    conn
    |> put_flash(:error, @sign_in_error)
    |> render("new.html", changeset: User.changeset(%User{}))
  end

  defp sign_in(_user, %{"password" => nil}, conn) do
    conn |> bad_sign_in
  end

  defp sign_in(user, %{"password" => password}, conn) do
    if Comeonin.Bcrypt.checkpw(password, user.password_hash) do
      conn
      |> put_flash(:info, "You are now signed in.")
      |> Guardian.Plug.sign_in(user)
      |> redirect(to: page_path(conn, :index))
    else
      conn
      |> put_flash(:error, @sign_in_error)
      |> render("new.html", changeset: User.changeset(%User{}))
    end
  end

  defp sign_in(_user, _params, conn), do: bad_sign_in(conn)
end
