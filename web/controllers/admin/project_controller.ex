defmodule Pairmotron.AdminProjectController do
  use Pairmotron.Web, :controller

  alias Pairmotron.Project

  def index(conn, _params) do
    projects = Repo.all(Project) |> Repo.preload([:group, :created_by])
    render(conn, "index.html", projects: projects)
  end

  def new(conn, _params) do
    changeset = Project.changeset(%Project{})
    groups = Repo.all(Pairmotron.Group)
    users = Repo.all(Pairmotron.User)
    render(conn, "new.html", changeset: changeset, groups: groups, users: users)
  end

  def create(conn, %{"project" => project_params}) do
    changeset = Project.changeset(%Project{}, project_params)
    groups = Repo.all(Pairmotron.Group)
    users = Repo.all(Pairmotron.User)

    case Repo.insert(changeset) do
      {:ok, _project} ->
        conn
        |> put_flash(:info, "Project created successfully.")
        |> redirect(to: admin_project_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, groups: groups, users: users)
    end
  end

  def show(conn, %{"id" => id}) do
    project = Repo.get!(Project, id) |> Repo.preload([:group, :created_by])
    render(conn, "show.html", project: project)
  end

  def edit(conn, %{"id" => id}) do
    project = Repo.get!(Project, id)
    changeset = Project.changeset(project)
    groups = Repo.all(Pairmotron.Group)
    users = Repo.all(Pairmotron.User)
    render(conn, "edit.html", project: project, changeset: changeset, groups: groups, users: users)
  end

  def update(conn, %{"id" => id, "project" => project_params}) do
    project = Repo.get!(Project, id)
    changeset = Project.changeset(project, project_params)
    groups = Repo.all(Pairmotron.Group)
    users = Repo.all(Pairmotron.User)

    case Repo.update(changeset) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "Project updated successfully.")
        |> redirect(to: admin_project_path(conn, :show, project))
      {:error, changeset} ->
        render(conn, "edit.html", project: project, changeset: changeset, groups: groups, users: users)
    end
  end

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
