defmodule Pairmotron.AdminGroupController do
  use Pairmotron.Web, :controller

  alias Pairmotron.Group

  def index(conn, _params) do
    groups = Repo.all(Group) |> Repo.preload(:owner)
    render(conn, "index.html", groups: groups)
  end

  def new(conn, _params) do
    changeset = Group.changeset(%Group{})
    users = Repo.all(Pairmotron.User)
    render(conn, "new.html", changeset: changeset, users: users)
  end

  def create(conn, %{"group" => group_params}) do
    changeset = Group.changeset(%Group{}, group_params)
    users = Repo.all(Pairmotron.User)

    case Repo.insert(changeset) do
      {:ok, _group} ->
        conn
        |> put_flash(:info, "Group created successfully.")
        |> redirect(to: admin_group_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, users: users)
    end
  end

  def show(conn, %{"id" => id}) do
    group = Repo.get!(Group, id) |> Repo.preload(:owner)
    render(conn, "show.html", group: group)
  end

  def edit(conn, %{"id" => id}) do
    group = Repo.get!(Group, id)
    changeset = Group.changeset(group)
    users = Repo.all(Pairmotron.User)
    render(conn, "edit.html", group: group, changeset: changeset, users: users)
  end

  def update(conn, %{"id" => id, "group" => group_params}) do
    group = Repo.get!(Group, id)
    changeset = Group.changeset(group, group_params)
    users = Repo.all(Pairmotron.User)

    case Repo.update(changeset) do
      {:ok, group} ->
        conn
        |> put_flash(:info, "Group updated successfully.")
        |> redirect(to: admin_group_path(conn, :show, group))
      {:error, changeset} ->
        render(conn, "edit.html", group: group, changeset: changeset, users: users)
    end
  end

  def delete(conn, %{"id" => id}) do
    group = Repo.get!(Group, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(group)

    conn
    |> put_flash(:info, "Group deleted successfully.")
    |> redirect(to: admin_group_path(conn, :index))
  end
end
