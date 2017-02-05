defmodule Pairmotron.PairController do
  use Pairmotron.Web, :controller

  alias Pairmotron.{Pair, PairRetro, User, UserPair, Mixer, Pairer, PairBuilder}

  def index(conn, _params) do
    {year, week} = Timex.iso_week(Timex.today)
    pairs = fetch_or_gen(year, week)
    conn = assign_current_user_pair_retro_for_week(conn, year, week)
    render conn, "index.html", pairs: pairs, year: year, week: week
  end

  def show(conn, %{"year" => y, "week" => w}) do
    {year, _} = y |> Integer.parse
    {week, _} = w |> Integer.parse
    pairs = fetch_or_gen(year, week)
    conn = assign_current_user_pair_retro_for_week(conn, year, week)
    render conn, "index.html", pairs: pairs, year: year, week: week
  end

  def delete(conn, %{"year" => y, "week" => w}) do
    {year, _} = y |> Integer.parse
    {week, _} = w |> Integer.parse
    generate_pairs(year, week)
    conn
      |> put_flash(:info, "Repairified")
      |> redirect(to: pair_path(conn, :show, year, week))
  end

  defp fetch_or_gen(year, week) do
    case fetch_pairs(year, week) do
      []    -> generate_and_fetch_if_current_week(year, week)
      pairs -> pairs
    end
      |> fetch_users_from_pairs
  end

  defp generate_and_fetch_if_current_week(year, week) do
    case Pairmotron.Calendar.same_week?(year, week, Timex.today) do
      true ->
        generate_pairs(year, week)
        fetch_pairs(year, week)
      false -> []
    end
  end

  defp fetch_pairs(year, week) do
    Pair
      |> where(year: ^year, week: ^week)
      |> order_by(:id)
      |> Repo.all
  end

  defp fetch_users_from_pairs(pairs) do
    pairs
      |> Repo.preload([:users])
  end

  defp generate_pairs(year, week) do
    users = User.active_users
      |> order_by(:id)
      |> Repo.all

    pairs = fetch_pairs(year, week)
      |> Repo.preload(:users)

    determination = PairBuilder.determify(pairs, users)

    determination.dead_pairs
      |> Enum.map(fn(p) -> Repo.delete! p end)

    pairs = determination.remaining_pairs
      |> Repo.preload(:pair_retros)
      |> Enum.filter(&(Enum.empty?(&1.pair_retros)))

    results = determination.available_users
      |> Mixer.mixify(week)
      |> Pairer.generate_pairs(pairs)

    results.pairs
      |> Enum.map(fn(users) -> make_pairs(users, year, week) end)
      |> List.flatten
      |> Enum.map(fn(p) -> Repo.insert! p end)

    insert_user_pair(results.user_pair)
  end

  defp insert_user_pair(nil), do: nil
  defp insert_user_pair(user_pair) do
    Repo.insert! user_pair
  end

  defp make_pairs(users, year, week) do
    pair = Repo.insert! Pair.changeset(%Pair{}, %{year: year, week: week})
    users
      |> Enum.map(fn(user) -> UserPair.changeset(%UserPair{}, %{pair_id: pair.id, user_id: user.id}) end)
  end

  defp assign_current_user_pair_retro_for_week(conn, year, week) do
    current_user = conn.assigns[:current_user]
    retro = Repo.one(PairRetro.retro_for_user_and_week(current_user, year, week))
    Plug.Conn.assign(conn, :current_user_retro_for_week, retro)
  end
end
