defmodule Pairmotron.SessionController do
  @moduledoc """
  Handles users logging in and logging out.
  """
  use Pairmotron.Web, :controller

  alias Pairmotron.User

  plug :scrub_params, "user" when action in [:create]

  @spec new(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def new(conn, _params) do
    if Guardian.Plug.current_resource(conn) do
      conn |> redirect(to: pair_path(conn, :index))
    else
      render conn, changeset: User.changeset(%User{})
    end
  end

  @spec create(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def create(conn, %{"user" => %{"email" => nil}}) do
    conn |> bad_sign_in
  end
  def create(conn, %{"user" => user_params = %{"email" => email}}) do
    User
    |> Repo.get_by(email: email)
    |> sign_in(user_params, conn)
  end
  def create(conn, _params), do: bad_sign_in(conn)

  @spec delete(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def delete(conn, _) do
    conn
    |> Guardian.Plug.sign_out
    |> put_flash(:info, "You have been logged out")
    |> redirect(to: session_path(conn, :new))
  end

  @sign_in_error "Name and/or password are incorrect."

  @spec bad_sign_in(%Plug.Conn{}) :: %Plug.Conn{}
  defp bad_sign_in(conn) do
    conn
    |> put_flash(:error, @sign_in_error)
    |> render("new.html", changeset: User.changeset(%User{}))
  end

  @spec sign_in(any(), map(), %Plug.Conn{}) :: %Plug.Conn{}
  defp sign_in(nil, _, conn), do: bad_sign_in(conn)
  defp sign_in(_, %{"password" => nil}, conn), do: bad_sign_in(conn)
  defp sign_in(user, %{"password" => password}, conn) do
    if Comeonin.Bcrypt.checkpw(password, user.password_hash) do
      conn
      |> put_flash(:info, "You are now signed in.")
      |> Guardian.Plug.sign_in(user)
      |> redirect(to: pair_path(conn, :index))
    else
      conn
      |> put_flash(:error, @sign_in_error)
      |> render("new.html", changeset: User.changeset(%User{}))
    end
  end
  defp sign_in(_user, _params, conn), do: bad_sign_in(conn)
end
