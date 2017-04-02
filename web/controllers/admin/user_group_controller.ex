defmodule Pairmotron.AdminUserGroupController do
  use Pairmotron.Web, :controller

  alias Pairmotron.UserGroup

  def index(conn, _params) do
    user_groups = Repo.all(UserGroup) |> Repo.preload([:group, :user])
    render(conn, "index.html", user_groups: user_groups)
  end

  def new(conn, _params) do
    changeset = UserGroup.changeset(%UserGroup{})
    groups = Repo.all(Pairmotron.Group)
    users = Repo.all(Pairmotron.User)
    render(conn, "new.html", changeset: changeset, groups: groups, users: users)
  end

  def create(conn, %{"user_group" => user_group_params}) do
    changeset = UserGroup.changeset(%UserGroup{}, user_group_params)
    groups = Repo.all(Pairmotron.Group)
    users = Repo.all(Pairmotron.User)

    case Repo.insert(changeset) do
      {:ok, _user_group} ->
        conn
        |> put_flash(:info, "UserGroup created successfully.")
        |> redirect(to: admin_user_group_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, groups: groups, users: users)
    end
  end

  def show(conn, %{"id" => id}) do
    user_group = Repo.get!(UserGroup, id) |> Repo.preload([:group, :user])
    render(conn, "show.html", user_group: user_group)
  end

  def edit(conn, %{"id" => id}) do
    user_group = Repo.get!(UserGroup, id)
    changeset = UserGroup.changeset(user_group)
    groups = Repo.all(Pairmotron.Group)
    users = Repo.all(Pairmotron.User)
    render(conn, "edit.html", user_group: user_group, changeset: changeset, groups: groups, users: users)
  end

  def update(conn, %{"id" => id, "user_group" => user_group_params}) do
    user_group = Repo.get!(UserGroup, id)
    changeset = UserGroup.changeset(user_group, user_group_params)
    groups = Repo.all(Pairmotron.Group)
    users = Repo.all(Pairmotron.User)

    case Repo.update(changeset) do
      {:ok, user_group} ->
        conn
        |> put_flash(:info, "UserGroup updated successfully.")
        |> redirect(to: admin_user_group_path(conn, :show, user_group))
      {:error, changeset} ->
        render(conn, "edit.html", user_group: user_group, changeset: changeset, groups: groups, users: users)
    end
  end

  def delete(conn, %{"id" => id}) do
    user_group = Repo.get!(UserGroup, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user_group)

    conn
    |> put_flash(:info, "UserGroup deleted successfully.")
    |> redirect(to: admin_user_group_path(conn, :index))
  end
end
