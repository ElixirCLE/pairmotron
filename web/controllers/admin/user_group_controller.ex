defmodule Pairmotron.AdminUserGroupController do
  use Pairmotron.Web, :controller

  alias Pairmotron.{Group, User, UserGroup}

  @spec index(Plug.Conn.t, map()) :: Plug.Conn.t
  def index(conn, _params) do
    user_groups = UserGroup |> Repo.all |> Repo.preload([:group, :user])
    render(conn, "index.html", user_groups: user_groups)
  end

  @spec new(Plug.Conn.t, map()) :: Plug.Conn.t
  def new(conn, _params) do
    changeset = UserGroup.changeset(%UserGroup{})
    {groups, users} = retrieve_groups_and_users()
    render(conn, "new.html", changeset: changeset, groups: groups, users: users)
  end

  @spec create(Plug.Conn.t, map()) :: Plug.Conn.t
  def create(conn, %{"user_group" => user_group_params}) do
    changeset = UserGroup.changeset(%UserGroup{}, user_group_params)
    {groups, users} = retrieve_groups_and_users()

    case Repo.insert(changeset) do
      {:ok, _user_group} ->
        conn
        |> put_flash(:info, "UserGroup created successfully.")
        |> redirect(to: admin_user_group_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, groups: groups, users: users)
    end
  end

  @spec show(Plug.Conn.t, map()) :: Plug.Conn.t
  def show(conn, %{"id" => id}) do
    user_group = UserGroup |> Repo.get!(id) |> Repo.preload([:group, :user])
    render(conn, "show.html", user_group: user_group)
  end

  @spec edit(Plug.Conn.t, map()) :: Plug.Conn.t
  def edit(conn, %{"id" => id}) do
    user_group = Repo.get!(UserGroup, id)
    changeset = UserGroup.changeset(user_group)
    {groups, users} = retrieve_groups_and_users()
    render(conn, "edit.html", user_group: user_group, changeset: changeset, groups: groups, users: users)
  end

  @spec update(Plug.Conn.t, map()) :: Plug.Conn.t
  def update(conn, %{"id" => id, "user_group" => user_group_params}) do
    user_group = Repo.get!(UserGroup, id)
    changeset = UserGroup.changeset(user_group, user_group_params)
    {groups, users} = retrieve_groups_and_users()
    render(conn, "edit.html", user_group: user_group, changeset: changeset, groups: groups, users: users)

    case Repo.update(changeset) do
      {:ok, user_group} ->
        conn
        |> put_flash(:info, "UserGroup updated successfully.")
        |> redirect(to: admin_user_group_path(conn, :show, user_group))
      {:error, changeset} ->
        render(conn, "edit.html", user_group: user_group, changeset: changeset, groups: groups, users: users)
    end
  end

  @spec delete(Plug.Conn.t, map()) :: Plug.Conn.t
  def delete(conn, %{"id" => id}) do
    user_group = Repo.get!(UserGroup, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user_group)

    conn
    |> put_flash(:info, "UserGroup deleted successfully.")
    |> redirect(to: admin_user_group_path(conn, :index))
  end

  @spec retrieve_groups_and_users() :: {Types.group, Types.user}
  defp retrieve_groups_and_users() do
    groups = Group 
      |> Repo.all
      |> Enum.sort(&(String.downcase(&1.name) <= String.downcase(&2.name)))
    users = User 
      |> Repo.all
      |> Enum.sort(&(String.downcase(&1.name) <= String.downcase(&2.name)))
    {groups, users}
  end
end
