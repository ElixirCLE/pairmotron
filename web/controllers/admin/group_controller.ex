defmodule Pairmotron.AdminGroupController do
  use Pairmotron.Web, :controller

  alias Pairmotron.Group

  @spec index(Plug.Conn.t, map()) :: Plug.Conn.t
  def index(conn, _params) do
    groups = Group |> Repo.all |> Repo.preload(:owner)
    render(conn, "index.html", groups: groups)
  end

  @spec new(Plug.Conn.t, map()) :: Plug.Conn.t
  def new(conn, _params) do
    changeset = Group.changeset(%Group{})
    users = retrieve_users()
    render(conn, "new.html", changeset: changeset, users: users)
  end

  @spec create(Plug.Conn.t, map()) :: Plug.Conn.t
  def create(conn, %{"group" => group_params}) do
    changeset = Group.changeset(%Group{}, group_params)
    users = retrieve_users()

    case Repo.insert(changeset) do
      {:ok, _group} ->
        conn
        |> put_flash(:info, "Group created successfully.")
        |> redirect(to: admin_group_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, users: users)
    end
  end

  @spec show(Plug.Conn.t, map()) :: Plug.Conn.t
  def show(conn, %{"id" => id}) do
    group = Group |> Repo.get!(id) |> Repo.preload(:owner)
    render(conn, "show.html", group: group)
  end

  @spec edit(Plug.Conn.t, map()) :: Plug.Conn.t
  def edit(conn, %{"id" => id}) do
    group = Repo.get!(Group, id)
    changeset = Group.changeset(group)
    users = retrieve_users()
    render(conn, "edit.html", group: group, changeset: changeset, users: users)
  end

  @spec update(Plug.Conn.t, map()) :: Plug.Conn.t
  def update(conn, %{"id" => id, "group" => group_params}) do
    group = Repo.get!(Group, id)
    changeset = Group.changeset(group, group_params)
    users = retrieve_users()

    case Repo.update(changeset) do
      {:ok, group} ->
        conn
        |> put_flash(:info, "Group updated successfully.")
        |> redirect(to: admin_group_path(conn, :show, group))
      {:error, changeset} ->
        render(conn, "edit.html", group: group, changeset: changeset, users: users)
    end
  end

  @spec delete(Plug.Conn.t, map()) :: Plug.Conn.t
  def delete(conn, %{"id" => id}) do
    group = Repo.get!(Group, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(group)

    conn
    |> put_flash(:info, "Group deleted successfully.")
    |> redirect(to: admin_group_path(conn, :index))
  end

  @spec retrieve_users() :: Types.user
  defp retrieve_users() do
    User 
    |> Repo.all
    |> Enum.sort(&(String.downcase(&1.name) <= String.downcase(&2.name)))
  end
end
