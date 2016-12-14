defmodule Pairmotron.ControllerTestHelper do
  def log_in(conn, user) do
    conn |> Plug.Conn.assign(:current_user, user)
  end

  def create_pair(users) do
    {year, week} = Timex.iso_week(Timex.today)
    create_pair(users, year, week)
  end

  def create_pair(users, year, week) do
    pair_changeset = Pairmotron.Pair.changeset(%Pairmotron.Pair{}, %{year: year, week: week})
    pair = Pairmotron.Repo.insert!(pair_changeset)
    users
    |> Enum.map(&(Pairmotron.UserPair.changeset(%Pairmotron.UserPair{}, %{pair_id: pair.id, user_id: &1.id})))
    |> List.flatten
    |> Enum.map(&(Pairmotron.Repo.insert! &1))
    pair
  end
end
