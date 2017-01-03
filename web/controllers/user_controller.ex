defmodule Pairmotron.UserController do
  use Pairmotron.Web, :controller

  alias Pairmotron.User
  import Pairmotron.ControllerHelpers

  plug :load_and_authorize_resource, model: User, only: [:delete]

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = User.registration_changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user, user_params)

    if current_assigned_user_id(conn) != id && changeset.changes[:password] do
      conn
      |> put_flash(:info, "You cannot change the password for a different user")
      |> render("edit.html", user: user, changeset: changeset)
    else
      _update(conn, user, changeset)
    end
  end

  defp _update(conn, user, changeset) do
    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, _params) do
    if conn.assigns.authorized do
      Repo.delete!(conn.assigns.user)

      conn
      |> put_flash(:info, "User deleted successfully.")
      |> redirect(to: user_path(conn, :index))
    else
      redirect_not_authorized(conn, user_path(conn, :index))
    end
  end

  defp current_assigned_user_id(conn) do
    case user = conn.assigns[:current_user] do
      %User{} -> Integer.to_string(user.id)
      _ -> nil
    end
  end
end
