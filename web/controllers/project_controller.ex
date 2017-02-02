defmodule Pairmotron.ProjectController do
  use Pairmotron.Web, :controller

  alias Pairmotron.Project
  import Pairmotron.ControllerHelpers

  plug :load_and_authorize_resource, model: Project, only: [:edit, :update, :delete]

  def index(conn, _params) do
    projects = Repo.all(Project.projects_for_user(conn.assigns.current_user))
               |> Repo.preload(:group)
    render(conn, "index.html", projects: projects)
  end

  def new(conn, _params) do
    changeset = Project.changeset(%Project{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"project" => project_params}) do
    changeset = Project.changeset(%Project{}, project_params)

    case Repo.insert(changeset) do
      {:ok, _project} ->
        conn
        |> put_flash(:info, "Project created successfully.")
        |> redirect(to: project_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    project = Repo.get!(Project, id)
    render(conn, "show.html", project: project)
  end

  def edit(conn = @authorized_conn, _params) do
    project = conn.assigns.project
    changeset = Project.changeset(project)
    render(conn, "edit.html", project: project, changeset: changeset)
  end
  def edit(conn, _params) do
    redirect_not_authorized(conn, project_path(conn, :index))
  end

  def update(conn = @authorized_conn, %{"project" => project_params}) do
    project = conn.assigns.project
    changeset = Project.changeset(project, project_params)

    case Repo.update(changeset) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "Project updated successfully.")
        |> redirect(to: project_path(conn, :show, project))
      {:error, changeset} ->
        render(conn, "edit.html", project: project, changeset: changeset)
    end
  end
  def update(conn, _params) do
    redirect_not_authorized(conn, project_path(conn, :index))
  end

  def delete(conn = @authorized_conn, _params) do
    project = conn.assigns.project

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(project)

    conn
    |> put_flash(:info, "Project deleted successfully.")
    |> redirect(to: project_path(conn, :index))
  end
  def delete(conn, _params) do
    redirect_not_authorized(conn, project_path(conn, :index))
  end
end
