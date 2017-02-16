defmodule Pairmotron.PairController do
  use Pairmotron.Web, :controller

  import Pairmotron.ControllerHelpers
  alias Pairmotron.PairMaker

  def index(conn, _params) do
    {year, week} = Timex.iso_week(Timex.today)
    user = conn.assigns[:current_user]
    groups_and_pairs = fetch_pairs_per_group(year, week, user)
    conn = assign_current_user_pair_retro_for_week(conn, year, week)
    render conn, "index.html", year: year, week: week, groups_and_pairs: groups_and_pairs
  end

  def show(conn, %{"year" => y, "week" => w}) do
    {year, _} = y |> Integer.parse
    {week, _} = w |> Integer.parse
    user = conn.assigns[:current_user]
    groups_and_pairs = fetch_pairs_per_group(year, week, user)
    conn = assign_current_user_pair_retro_for_week(conn, year, week)
    render conn, "index.html", year: year, week: week, groups_and_pairs: groups_and_pairs
  end

  defp fetch_pairs_per_group(year, week, user) do
    user = user
      |> Repo.preload(:groups)
    pairs = user.groups
      |> Enum.map(fn(g) ->
        PairMaker.fetch_or_gen(year, week, g.id)
          |> Enum.filter(fn(p) ->
               member_ids = p.users |> Enum.map(&(&1.id))
               Enum.member?(member_ids, user.id)
             end)
      end)
    Enum.zip(user.groups, pairs)
  end
end
