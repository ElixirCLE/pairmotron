defmodule Pairmotron.PairController do
  use Pairmotron.Web, :controller

  import Pairmotron.ControllerHelpers
  alias Pairmotron.PairMaker

  def index(conn, _params) do
    {year, week} = Timex.iso_week(Timex.today)
    user = conn.assigns[:current_user]
    groups_and_pairs = fetch_pairs(year, week, user)
    conn = assign_current_user_pair_retro_for_week(conn, year, week)
    render conn, "index.html", year: year, week: week, groups_and_pairs: groups_and_pairs,
      start_date: Timex.from_iso_triplet({year, week, 1}),
      stop_date: Timex.from_iso_triplet({year, week, 7})
  end

  def show(conn, %{"year" => y, "week" => w}) do
    {year, _} = y |> Integer.parse
    {week, _} = w |> Integer.parse
    user = conn.assigns[:current_user]
    groups_and_pairs = fetch_pairs(year, week, user)
    conn = assign_current_user_pair_retro_for_week(conn, year, week)
    render conn, "index.html", year: year, week: week, groups_and_pairs: groups_and_pairs,
      start_date: Timex.from_iso_triplet({year, week, 1}),
      stop_date: Timex.from_iso_triplet({year, week, 7})
  end

  defp fetch_pairs(year, week, user) do
    user = user
      |> Repo.preload(:groups)
    pairs = user
      |> pairs_for_user_groups(year, week)
    Enum.zip(user.groups, pairs)
  end

  defp pairs_for_user_groups(user, year, week) do
    user.groups
      |> Enum.map(fn(group) ->
        PairMaker.fetch_or_gen(year, week, group.id)
        |> pairs_containing_user(user)
      end)
  end

  defp pairs_containing_user(pairs, user) do
    pairs
      |> Enum.filter(fn(pair) ->
           member_ids = pair.users |> Enum.map(&(&1.id))
             Enum.member?(member_ids, user.id)
         end)
  end
end
