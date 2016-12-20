defmodule Pairmotron.TestHelper do

  alias Pairmotron.{Pair, PairRetro, Repo, UserPair}

  def log_in(conn, user) do
    conn |> Plug.Conn.assign(:current_user, user)
  end

  def create_pair(users) do
    {year, week} = Timex.iso_week(Timex.today)
    create_pair(users, year, week)
  end

  def create_pair(users, year, week) do
    pair_changeset = Pair.changeset(%Pair{}, %{year: year, week: week})
    pair = Pairmotron.Repo.insert!(pair_changeset)
    users
    |> Enum.map(&(UserPair.changeset(%UserPair{}, %{pair_id: pair.id, user_id: &1.id})))
    |> List.flatten
    |> Enum.map(&(Repo.insert! &1))
    pair
  end

  def create_retro(user, pair) do
    retro_changeset = PairRetro.changeset(%PairRetro{}, %{comment: "comment", pair_date: Timex.today, user_id: user.id, pair_id: pair.id})
    Repo.insert!(retro_changeset)
  end

  def create_retro(user, pair, project) do
    retro_changeset = PairRetro.changeset(%PairRetro{}, %{comment: "comment", pair_date: Timex.today, user_id: user.id, pair_id: pair.id, project_id: project.id})
    Repo.insert!(retro_changeset)
  end
end
