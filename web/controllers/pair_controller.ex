defmodule Pairmotron.PairController do
  use Pairmotron.Web, :controller

  import Pairmotron.ControllerHelpers
  alias Pairmotron.PairMaker

  def index(conn, _params) do
    {year, week} = Timex.iso_week(Timex.today)
    user = conn.assigns[:current_user]
      |> Repo.preload(:groups)
    pairs = user.groups
      |> Enum.map(fn(g) ->
        PairMaker.fetch_or_gen(year, week, g.id)
          |> Enum.filter(fn(p) -> !Enum.member?(p.users, user) end)
      end)
    groups_and_pairs = Enum.zip(user.groups, pairs)
    conn = assign_current_user_pair_retro_for_week(conn, year, week)
    render conn, "index.html", year: year, week: week, groups_and_pairs: groups_and_pairs
  end

  def show(conn, %{"year" => y, "week" => w}) do
    {year, _} = y |> Integer.parse
    {week, _} = w |> Integer.parse
    user = conn.assigns[:current_user]
      |> Repo.preload(:groups)
    pairs = user.groups
      |> Enum.map(fn(g) ->
        PairMaker.fetch_or_gen(year, week, g.id)
          |> Enum.filter(fn(p) -> !Enum.member?(p.users, user) end)
      end)
    groups_and_pairs = Enum.zip(user.groups, pairs)
    conn = assign_current_user_pair_retro_for_week(conn, year, week)
    render conn, "index.html", year: year, week: week, groups_and_pairs: groups_and_pairs
  end
end
