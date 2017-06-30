defmodule Pairmotron.AdminProjectController do
  use Pairmotron.Web, :controller

  alias Pairmotron.Project

  @spec index(Plug.Conn.t, map()) :: Plug.Conn.t
  def index(conn, _params) do
    projects = Project |> Repo.all |> Repo.preload([:group, :created_by])
    render(conn, "index.html", projects: projects)
  end

  @spec new(Plug.Conn.t, map()) :: Plug.Conn.t
  def new(conn, _params) do
    changeset = Project.changeset(%Project{})
    groups = Repo.all(Pairmotron.Group)
      |> Enum.sort(&(String.downcase(&1.name) <= String.downcase(&2.name)))
    users = Repo.all(Pairmotron.User)
      |> Enum.sort(&(String.downcase(&1.name) <= String.downcase(&2.name)))
    render(conn, "new.html", changeset: changeset, groups: groups, users: users)
  end

  @spec create(Plug.Conn.t, map()) :: Plug.Conn.t
  def create(conn, %{"project" => project_params}) do
    changeset = Project.changeset(%Project{}, project_params)
    groups = Repo.all(Pairmotron.Group)
      |> Enum.sort(&(String.downcase(&1.name) <= String.downcase(&2.name)))
    users = Repo.all(Pairmotron.User)
      |> Enum.sort(&(String.downcase(&1.name) <= String.downcase(&2.name)))

    case Repo.insert(changeset) do
      {:ok, _project} ->
        conn
        |> put_flash(:info, "Project created successfully.")
        |> redirect(to: admin_project_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, groups: groups, users: users)
    end
  end

  @spec show(Plug.Conn.t, map()) :: Plug.Conn.t
  def show(conn, %{"id" => id}) do
    project = Project |> Repo.get!(id) |> Repo.preload([:group, :created_by])
    render(conn, "show.html", project: project)
  end

  @spec edit(Plug.Conn.t, map()) :: Plug.Conn.t
  def edit(conn, %{"id" => id}) do
    project = Repo.get!(Project, id)
    changeset = Project.changeset(project)
    groups = Repo.all(Pairmotron.Group)
      |> Enum.sort(&(String.downcase(&1.name) <= String.downcase(&2.name)))
    users = Repo.all(Pairmotron.User)
      |> Enum.sort(&(String.downcase(&1.name) <= String.downcase(&2.name)))
    render(conn, "edit.html", project: project, changeset: changeset, groups: groups, users: users)
  end

  @spec update(Plug.Conn.t, map()) :: Plug.Conn.t
  def update(conn, %{"id" => id, "project" => project_params}) do
    project = Repo.get!(Project, id)
    changeset = Project.changeset(project, project_params)
    groups = Repo.all(Pairmotron.Group)
      |> Enum.sort(&(String.downcase(&1.name) <= String.downcase(&2.name)))
    users = Repo.all(Pairmotron.User)
      |> Enum.sort(&(String.downcase(&1.name) <= String.downcase(&2.name)))

    case Repo.update(changeset) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "Project updated successfully.")
        |> redirect(to: admin_project_path(conn, :show, project))
      {:error, changeset} ->
        render(conn, "edit.html", project: project, changeset: changeset, groups: groups, users: users)
    end
  end

  @spec delete(Plug.Conn.t, map()) :: Plug.Conn.t
  def delete(conn, %{"id" => id}) do
    project = Repo.get!(Project, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(project)

    conn
    |> put_flash(:info, "Project deleted successfully.")
    |> redirect(to: admin_project_path(conn, :index))
  end
end
