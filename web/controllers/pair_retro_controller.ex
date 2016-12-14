defmodule Pairmotron.PairRetroController do
  use Pairmotron.Web, :controller

  alias Pairmotron.PairRetro

  def index(conn, _params) do
    pair_retros = Repo.all(PairRetro)
    render(conn, "index.html", pair_retros: pair_retros)
  end

  def new(conn, params = %{"pair_id" => pair_id}) do
    changeset = PairRetro.changeset(%PairRetro{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"pair_retro" => pair_retro_params}) do
    changeset = PairRetro.changeset(%PairRetro{}, pair_retro_params)

    case Repo.insert(changeset) do
      {:ok, _pair_retro} ->
        conn
        |> put_flash(:info, "Pair retro created successfully.")
        |> redirect(to: pair_retro_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    pair_retro = Repo.get!(PairRetro, id)
    render(conn, "show.html", pair_retro: pair_retro)
  end

  def edit(conn, %{"id" => id}) do
    pair_retro = Repo.get!(PairRetro, id)
    changeset = PairRetro.changeset(pair_retro)
    render(conn, "edit.html", pair_retro: pair_retro, changeset: changeset)
  end

  def update(conn, %{"id" => id, "pair_retro" => pair_retro_params}) do
    pair_retro = Repo.get!(PairRetro, id)
    changeset = PairRetro.changeset(pair_retro, pair_retro_params)

    case Repo.update(changeset) do
      {:ok, pair_retro} ->
        conn
        |> put_flash(:info, "Pair retro updated successfully.")
        |> redirect(to: pair_retro_path(conn, :show, pair_retro))
      {:error, changeset} ->
        render(conn, "edit.html", pair_retro: pair_retro, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    pair_retro = Repo.get!(PairRetro, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(pair_retro)

    conn
    |> put_flash(:info, "Pair retro deleted successfully.")
    |> redirect(to: pair_retro_path(conn, :index))
  end
end
