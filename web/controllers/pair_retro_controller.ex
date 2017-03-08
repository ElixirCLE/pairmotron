defmodule Pairmotron.PairRetroController do
  use Pairmotron.Web, :controller

  alias Pairmotron.{PairRetro, Project, Pair}
  import Pairmotron.ControllerHelpers

  plug :load_and_authorize_resource, model: PairRetro, only: [:show, :edit, :update, :delete]

  @spec index(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def index(conn, _params) do
    pair_retros = conn.assigns.current_user
      |> PairRetro.users_retros
      |> Repo.all
      |> Repo.preload(:project)
    render(conn, "index.html", pair_retros: pair_retros)
  end

  @spec new(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def new(conn, %{"pair_id" => pair_id}) do
    current_user = conn.assigns.current_user

    pair = pair_id |> Pair.pair_with_users |> Repo.one

    cond do
      is_nil(pair) ->
        redirect_and_flash_error(conn, "You cannot create a retrospective for a non-existent pair")
      not current_user.id in Enum.map(pair.users, &(&1.id)) ->
        redirect_and_flash_error(conn, "You cannot create a retrospective for a pair you are not in")
      true ->
        projects = pair.group_id |> Project.projects_for_group |> Repo.all
        current_user = conn.assigns[:current_user]
        changeset = PairRetro.changeset(%PairRetro{}, %{pair_id: pair_id, user_id: current_user.id}, nil, nil)
        render(conn, "new.html", changeset: changeset, projects: projects)
    end
  end

  @spec create(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def create(conn, %{"pair_retro" => pair_retro_params}) do
    current_user = conn.assigns.current_user

    pair_id = parameter_as_integer(pair_retro_params, "pair_id")
    pair = pair_id |> Pair.pair_with_users |> Repo.one

    cond do
      is_nil(pair) ->
        redirect_and_flash_error(conn, "You cannot create a retrospective for a non-existent pair")
      not current_user.id in Enum.map(pair.users, &(&1.id)) ->
        redirect_and_flash_error(conn, "You cannot create a retrospective for a pair you are not in")
      true ->
        implicit_params = %{"user_id" => conn.assigns.current_user.id}
        final_params = pair_retro_params |> Map.merge(implicit_params)

        project_id = Map.get(final_params, "project_id", 0)
        project = Repo.get(Project, project_id)

        changeset = PairRetro.changeset(%PairRetro{}, final_params, pair, project)
        case Repo.insert(changeset) do
          {:ok, _pair_retro} ->
            conn
            |> put_flash(:info, "Pair retro created successfully.")
            |> redirect(to: pair_retro_path(conn, :index))
          {:error, changeset} ->
            projects = pair.group_id |> Project.projects_for_group |> Repo.all
            render(conn, "new.html", changeset: changeset, projects: projects)
        end
    end
  end

  @spec show(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def show(conn = @authorized_conn, _params) do
    pair_retro = Repo.preload(conn.assigns.pair_retro, :project)
    render(conn, "show.html", pair_retro: pair_retro)
  end
  def show(conn, _params) do
    redirect_not_authorized(conn, pair_retro_path(conn, :index))
  end

  @spec edit(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def edit(conn = @authorized_conn, _params) do
    retro = conn.assigns.pair_retro |> Repo.preload(:pair)
    projects = retro.pair.group_id |> Project.projects_for_group |> Repo.all
    changeset = PairRetro.changeset(retro, %{}, nil, nil)
    render(conn, "edit.html", pair_retro: retro, changeset: changeset, projects: projects)
  end
  def edit(conn, _params) do
    redirect_not_authorized(conn, pair_retro_path(conn, :index))
  end

  @spec update(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def update(conn = @authorized_conn, %{"pair_retro" => pair_retro_params}) do
    pair_retro = conn.assigns.pair_retro |> Repo.preload([:pair, :project])
    pair = pair_retro.pair

    project = project_from_params_or_pair_retro(pair_retro_params, pair_retro)

    changeset = PairRetro.update_changeset(pair_retro, pair_retro_params, pair, project)

    case Repo.update(changeset) do
      {:ok, pair_retro} ->
        conn
        |> put_flash(:info, "Pair retro updated successfully.")
        |> redirect(to: pair_retro_path(conn, :show, pair_retro))
      {:error, changeset} ->
        projects = pair.group_id |> Project.projects_for_group |> Repo.all
        render(conn, "edit.html", pair_retro: pair_retro, changeset: changeset, projects: projects)
    end
  end
  def update(conn, _params) do
    redirect_not_authorized(conn, pair_retro_path(conn, :index))
  end

  @spec project_from_params_or_pair_retro(map(), Types.retro) :: nil | %Pairmotron.Project{}
  defp project_from_params_or_pair_retro(params, pair_retro) do
    case Map.get(params, "project_id") || (pair_retro.project && pair_retro.project.id) do
      nil -> nil
      id -> Repo.get(Project, id)
    end
  end

  @spec delete(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def delete(conn = @authorized_conn, _params) do
      Repo.delete!(conn.assigns.pair_retro)

      conn
      |> put_flash(:info, "Retrospective deleted successfully.")
      |> redirect(to: pair_retro_path(conn, :index))
  end
  def delete(conn, _params) do
    redirect_not_authorized(conn, pair_retro_path(conn, :index))
  end

  @spec redirect_and_flash_error(%Plug.Conn{}, binary()) :: %Plug.Conn{}
  defp redirect_and_flash_error(conn, message) do
    conn
    |> put_flash(:error, message)
    |> redirect(to: pair_path(conn, :index))
  end
end
