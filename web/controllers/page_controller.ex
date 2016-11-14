defmodule Pairmotron.PageController do
  use Pairmotron.Web, :controller

  alias Pairmotron.Pair
  alias Pairmotron.User
  alias Pairmotron.UserPair
  alias Pairmotron.Mixer
  alias Pairmotron.Pairer

  def index(conn, _params) do
    {year, week} = Timex.iso_week(Timex.today)
    pairs = fetch_or_gen(year, week)
    render conn, "index.html", pairs: pairs, year: year, week: week
  end

  def show(conn, %{"year" => y, "week" => w}) do
    {year, _} = y |> Integer.parse
    {week, _} = w |> Integer.parse
    pairs = fetch_or_gen(year, week)
    render conn, "index.html", pairs: pairs, year: year, week: week
  end

  def delete(conn, %{"year" => y, "week" => w}) do
    {year, _} = y |> Integer.parse
    {week, _} = w |> Integer.parse
    fetch_pairs(year, week)
      |> Enum.map(fn(p) -> Repo.delete! p end)
    conn
      |> put_flash(:info, "Repairified")
      |> redirect(to: page_path(conn, :show, year, week))
  end

  defp fetch_or_gen(year, week) do
    case fetch_pairs(year, week) do
      [] ->
        generate_pairs(year, week)
        fetch_pairs(year, week)
      pairs -> pairs
    end
      |> fetch_users_from_pairs
  end

  defp fetch_pairs(year, week) do
    Pair
      |> where(year: ^year, week: ^week)
      |> order_by(:pair_group)
      |> Repo.all
  end

  defp fetch_users_from_pairs(pairs) do
    pairs
      |> Repo.preload([:users])
  end

  defp generate_pairs(year, week) do
    User.active_users
      |> order_by(:id)
      |> Repo.all
      |> Mixer.mixify(week)
      |> Pairer.generate_pairs
      |> Enum.with_index
      |> Enum.map(fn({users, pair_index}) -> make_pair(users, pair_index, year, week) end)
      |> List.flatten
      |> Enum.map(fn(p) -> Repo.insert! p end)
  end

  defp make_pair(users, index, year, week) do
    pair = Repo.insert! %Pair{year: year, week: week, pair_group: index}
    users
      |> Enum.map(fn(user) -> %UserPair{pair_id: pair.id, user_id: user.id} end)
  end
end
