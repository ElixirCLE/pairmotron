defmodule Pairmotron.TestHelper do

  alias Pairmotron.{Pair, PairRetro, Repo, UserPair}
  require Phoenix.ConnTest
  @endpoint Pairmotron.Endpoint

  def log_in(conn, user) do
    conn |> Plug.Conn.assign(:current_user, user)
  end

  def guardian_log_in(conn, user) do
    conn
    |> Phoenix.ConnTest.bypass_through(Pairmotron.Router, [:browser])
    |> Phoenix.ConnTest.get("/")
    |> Guardian.Plug.sign_in(user, :token)
    |> Plug.Conn.send_resp(200, "Session Flushed")
    |> Phoenix.ConnTest.recycle()
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
    retro_changeset = PairRetro.changeset(%PairRetro{},
                                          %{subject:    "subject",
                                            reflection: "reflection",
                                            pair_date:  Timex.today,
                                            user_id:    user.id,
                                            pair_id:    pair.id},
                                          Timex.today)
    Repo.insert!(retro_changeset)
  end

  def create_retro(user, pair, project) do
    retro_changeset = PairRetro.changeset(%PairRetro{},
                                          %{subject: "subject",
                                            reflection: "reflection",
                                            pair_date: Timex.today,
                                            user_id: user.id,
                                            pair_id: pair.id,
                                            project_id: project.id},
                                          Timex.today)
    Repo.insert!(retro_changeset)
  end

  def create_pair_and_retro(user) do
    pair = create_pair([user])
    retro = create_retro(user, pair)
    {pair, retro}
  end
end
