defmodule Pairmotron.ProjectController do
  @moduledoc """
  Handles interactions with projects. Users can create and modify projects
  which are specific to a group. Projects are suggestions for what the Users in
  a Pair can work on together.
  """
  use Pairmotron.Web, :controller

  alias Pairmotron.{Group, Project}
  import Pairmotron.ControllerHelpers

  plug :load_and_authorize_resource, model: Project, only: [:show, :edit, :update, :delete]

  @spec index(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def index(conn, _params) do
    projects = conn.assigns.current_user
      |> Project.projects_for_user
      |> Repo.all
      |> Repo.preload(:group)
    render(conn, "index.html", projects: projects)
  end

  @spec new(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def new(conn, _params) do
    groups = conn.assigns.current_user
      |> Group.groups_for_user
      |> Repo.all

    case groups do
      [] ->
        render(conn, "no_groups.html")
      groups ->
        conn = assign(conn, :groups, groups)
        changeset = Project.changeset_for_create(%Project{}, %{}, groups)
        render(conn, "new.html", changeset: changeset)
    end
  end

  @spec create(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def create(conn, %{"project" => project_params}) do
    current_user = conn.assigns.current_user

    groups = current_user
      |> Group.groups_for_user
      |> Repo.all

    project_params = project_params |> Map.put("created_by_id", current_user.id)
    changeset = Project.changeset_for_create(%Project{}, project_params, groups)

    case Repo.insert(changeset) do
      {:ok, _project} ->
        conn
        |> put_flash(:info, "Project created successfully.")
        |> redirect(to: project_path(conn, :index))
      {:error, changeset} ->
        conn = assign(conn, :groups, groups)
        render(conn, "new.html", changeset: changeset)
    end
  end

  @spec show(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def show(conn = @authorized_conn, %{"id" => id}) do
    project = Project |> Repo.get!(id) |> Repo.preload(:group)
    render(conn, "show.html", project: project)
  end
  def show(conn, _params) do
    redirect_not_authorized(conn, project_path(conn, :index))
  end

  @spec edit(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def edit(conn = @authorized_conn, _params) do
    groups = conn.assigns.current_user
      |> Group.groups_for_user
      |> Repo.all
    conn = assign(conn, :groups, groups)
    project = conn.assigns.project
    changeset = Project.changeset(project)
    render(conn, "edit.html", project: project, changeset: changeset)
  end
  def edit(conn, _params) do
    redirect_not_authorized(conn, project_path(conn, :index))
  end

  @spec update(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def update(conn = @authorized_conn, %{"project" => project_params}) do
    project = conn.assigns.project
    changeset = Project.changeset_for_update(project, project_params)

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

  @spec delete(%Plug.Conn{}, map()) :: %Plug.Conn{}
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
