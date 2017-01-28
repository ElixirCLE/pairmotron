defmodule Pairmotron.ProfileController do
  use Pairmotron.Web, :controller

  alias Pairmotron.User

  def show(conn, _params) do
    user = conn.assigns.current_user |> Repo.preload(:groups)
    render(conn, "show.html", user: user)
  end

  def edit(conn, _params) do
    user = conn.assigns.current_user
    changeset = User.profile_changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"user" => user_params}) do
    user = conn.assigns.current_user
    changeset = User.profile_changeset(user, user_params)
    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Profile updated successfully.")
        |> redirect(to: profile_path(conn, :show))
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

end
