defmodule Pairmotron.PairController do
  @moduledoc """
  Handles interactions around Users looking at the pairs that they are in.
  """
  use Pairmotron.Web, :controller

  import Pairmotron.ControllerHelpers
  alias Pairmotron.PairMaker

  @spec index(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def index(conn, _params) do
    {year, week} = Timex.iso_week(Timex.today)
    user = conn.assigns[:current_user]
    {conn, groups_and_pairs} = conn
      |> assign_current_user_pair_retro_for_week(year, week)
      |> fetch_pairs(year, week, user)
    render conn, "index.html", year: year, week: week, groups_and_pairs: groups_and_pairs,
      start_date: Timex.from_iso_triplet({year, week, 1}),
      stop_date: Timex.from_iso_triplet({year, week, 7})
  end

  @spec show(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def show(conn, %{"year" => y, "week" => w}) do
    {year, _} = y |> Integer.parse
    {week, _} = w |> Integer.parse
    user = conn.assigns[:current_user]
    {conn, groups_and_pairs} = conn
      |> assign_current_user_pair_retro_for_week(year, week)
      |> fetch_pairs(year, week, user)
    render conn, "index.html", year: year, week: week, groups_and_pairs: groups_and_pairs,
      start_date: Timex.from_iso_triplet({year, week, 1}),
      stop_date: Timex.from_iso_triplet({year, week, 7})
  end

  @spec fetch_pairs(%Plug.Conn{}, integer(), 1..53, Types.user) :: {%Plug.Conn{}, [{Types.group, Types.pair}]}
  defp fetch_pairs(conn, year, week, user) do
    user = user
      |> Repo.preload(:groups)
    {conn, pairs} = user
      |> pairs_for_user_groups(conn, year, week)
    {conn, Enum.zip(user.groups, pairs)}
  end

  @spec pairs_for_user_groups(Types.user, %Plug.Conn{}, integer(), 1..53) :: {%Plug.Conn{}, [Types.pair]}
  defp pairs_for_user_groups(user, conn, year, week) do
    conn_and_pairs = {conn, []}
    user.groups
      |> Enum.reduce(conn_and_pairs, fn(group, conn_and_pairs) ->
        {conn, result_pairs} = conn_and_pairs
        case PairMaker.fetch_or_gen(year, week, group.id) do
          {:error, pairs, message} ->
            {conn |> put_flash(:error, message), result_pairs ++ [pairs |> pairs_containing_user(user)]}
          {:ok, pairs} ->
            {conn, result_pairs ++ [pairs |> pairs_containing_user(user)]}
        end
      end)
  end

  @spec pairs_containing_user([Types.pair], Types.user) :: [Types.pair]
  defp pairs_containing_user(pairs, user) do
    pairs
      |> Enum.filter(fn(pair) ->
           member_ids = pair.users |> Enum.map(&(&1.id))
           Enum.member?(member_ids, user.id)
         end)
  end
end
