defmodule Pairmotron.UserController do
  use Pairmotron.Web, :controller

  alias Pairmotron.User
  import Pairmotron.ControllerHelpers

  plug :load_and_authorize_resource, model: User, only: [:edit, :update, :delete]

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

  def edit(conn, _params) do
    if conn.assigns.authorized do
      user = conn.assigns.user
      changeset = User.changeset(user)
      render(conn, "edit.html", user: user, changeset: changeset)
    else
      redirect_not_authorized(conn, user_path(conn, :index))
    end
  end

  def update(conn, %{"user" => user_params}) do
    if conn.assigns.authorized do
      user = conn.assigns.user
      changeset = User.changeset(user, user_params)
      case Repo.update(changeset) do
        {:ok, user} ->
          conn
          |> put_flash(:info, "User updated successfully.")
          |> redirect(to: user_path(conn, :show, user))
        {:error, changeset} ->
          render(conn, "edit.html", user: user, changeset: changeset)
      end
    else
      redirect_not_authorized(conn, user_path(conn, :index))
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
end
