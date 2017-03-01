defmodule Pairmotron.PairRetroController do
  use Pairmotron.Web, :controller

  alias Pairmotron.{PairRetro, Project, Pair}
  import Pairmotron.ControllerHelpers

  plug :load_and_authorize_resource, model: PairRetro, only: [:show, :edit, :update, :delete]

  def index(conn, _params) do
    current_user = conn.assigns[:current_user]
    pair_retros = Repo.all(PairRetro.users_retros(current_user)) |> Repo.preload(:project)
    render(conn, "index.html", pair_retros: pair_retros)
  end

  def new(conn, %{"pair_id" => pair_id}) do
    conn = assign(conn, :projects, Repo.all(Project))
    current_user = conn.assigns[:current_user]
    changeset = PairRetro.changeset(%PairRetro{}, %{pair_id: pair_id, user_id: current_user.id}, nil)
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"pair_retro" => pair_retro_params}) do
    pair_id = parameter_as_integer(pair_retro_params, "pair_id")
    current_user = conn.assigns.current_user

    pair = Repo.get!(Pair, pair_id) |> Repo.preload(:users)
    pair_user_ids = pair.users |> Enum.map(&(&1.id))

    cond do
      not current_user.id in pair_user_ids ->
        redirect_not_authorized(conn, pair_retro_path(conn, :index))
      true ->
        implicit_params = %{"user_id" => conn.assigns.current_user.id}
        final_params = pair_retro_params |> Map.merge(implicit_params)

        earliest_pair_date = earliest_pair_date_from_params(pair_retro_params)
        changeset = PairRetro.changeset(%PairRetro{}, final_params, earliest_pair_date)
        case Repo.insert(changeset) do
          {:ok, _pair_retro} ->
            conn
            |> put_flash(:info, "Pair retro created successfully.")
            |> redirect(to: pair_retro_path(conn, :index))
          {:error, changeset} ->
            render(conn, "new.html", changeset: changeset)
        end
    end
  end

  def show(conn = @authorized_conn, _params) do
    pair_retro = Repo.preload(conn.assigns.pair_retro, :project)
    render(conn, "show.html", pair_retro: pair_retro)
  end
  def show(conn, _params) do
    redirect_not_authorized(conn, pair_retro_path(conn, :index))
  end

  def edit(conn = @authorized_conn, _params) do
    conn = assign(conn, :projects, Repo.all(Project))
    retro = conn.assigns.pair_retro
    changeset = PairRetro.changeset(retro, %{}, nil)
    render(conn, "edit.html", pair_retro: retro, changeset: changeset)
  end
  def edit(conn, _params) do
    redirect_not_authorized(conn, pair_retro_path(conn, :index))
  end

  def update(conn = @authorized_conn, %{"pair_retro" => pair_retro_params}) do
    pair_retro = conn.assigns.pair_retro |> Repo.preload(:pair)
    pair = pair_retro.pair

    earliest_pair_date = Pairmotron.Calendar.first_date_of_week(pair.year, pair.week)
    changeset = PairRetro.update_changeset(pair_retro, pair_retro_params, earliest_pair_date)

    case Repo.update(changeset) do
      {:ok, pair_retro} ->
        conn
        |> put_flash(:info, "Pair retro updated successfully.")
        |> redirect(to: pair_retro_path(conn, :show, pair_retro))
      {:error, changeset} ->
        render(conn, "edit.html", pair_retro: pair_retro, changeset: changeset)
    end
  end
  def update(conn, _params) do
    redirect_not_authorized(conn, pair_retro_path(conn, :index))
  end

  def delete(conn = @authorized_conn, _params) do
      Repo.delete!(conn.assigns.pair_retro)

      conn
      |> put_flash(:info, "Retrospective deleted successfully.")
      |> redirect(to: pair_retro_path(conn, :index))
  end
  def delete(conn, _params) do
    redirect_not_authorized(conn, pair_retro_path(conn, :index))
  end

  defp earliest_pair_date_from_params(params) do
    pair_id = parameter_as_integer(params, "pair_id")
    case Repo.get(Pairmotron.Pair, pair_id) do
      nil -> nil
      pair -> Pairmotron.Calendar.first_date_of_week(pair.year, pair.week)
    end
  end
end
