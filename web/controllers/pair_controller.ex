defmodule Pairmotron.PairController do
  @moduledoc """
  Handles interactions around Users looking at the pairs that they are in.
  """
  use Pairmotron.Web, :controller

  alias Pairmotron.PairMaker

  @spec index(Plug.Conn.t, map()) :: Plug.Conn.t
  def index(conn, _params) do
    {year, week} = Timex.iso_week(Timex.today)
    user = conn.assigns[:current_user]
    {groups_and_pairs, messages} = user |> fetch_groups_and_pairs(year, week)

    conn
    |> flash_messages(messages)
    |> render_index(year, week, groups_and_pairs)
  end

  @spec show(Plug.Conn.t, map()) :: Plug.Conn.t
  def show(conn, %{"year" => y, "week" => w}) do
    {year, _} = y |> Integer.parse
    {week, _} = w |> Integer.parse
    user = conn.assigns[:current_user]
    {groups_and_pairs, messages} = user |> fetch_groups_and_pairs(year, week)

    conn
    |> flash_messages(messages)
    |> render_index(year, week, groups_and_pairs)
  end

  @spec render_index(Plug.Conn.t, integer(), 1..53, [{Types.group, [Types.pair]}]) :: Plug.Conn.t
  defp render_index(conn, year, week, groups_and_pairs) do
    render(conn, "index.html", year: year, week: week, groups_and_pairs: groups_and_pairs,
              start_date: Timex.from_iso_triplet({year, week, 1}),
              stop_date: Timex.from_iso_triplet({year, week, 7}))
  end

  @spec fetch_groups_and_pairs(Types.user, integer(), 1..53) :: {[{Types.group, [Types.pair]}], [String.t]}
  defp fetch_groups_and_pairs(user, year, week) do
    user = user |> Repo.preload(:groups)
    groups_with_pairs_for_user(user, year, week)
  end

  @spec groups_with_pairs_for_user(Types.user, integer(), 1..53) :: {[{Types.group, [Types.pair]}], [String.t]}
  defp groups_with_pairs_for_user(user, year, week) do
    Enum.reduce(user.groups, {[], []},
      fn(group, accum) ->
        {groups_with_pairs, messages} = accum
        case PairMaker.fetch_or_gen(year, week, group.id) do
          {:ok, pairs} ->
            users_pairs = pairs_containing_user(pairs, user)
            new_groups_with_pairs = groups_with_pairs ++ [{group, users_pairs}]
            {new_groups_with_pairs, messages}
          {:error, pairs, message} ->
            users_pairs = pairs_containing_user(pairs, user)
            new_groups_with_pairs = groups_with_pairs ++ [{group, users_pairs}]
            {new_groups_with_pairs, [message | messages]}
        end
      end)
  end

  @spec pairs_containing_user([Types.pair], Types.user) :: [Types.pair]
  defp pairs_containing_user(pairs, user) do
    Enum.filter(pairs, fn(pair) ->
      member_ids = pair.users |> Enum.map(&(&1.id))
      Enum.member?(member_ids, user.id)
    end)
  end

  @spec flash_messages(Plug.Conn.t, [String.t]) :: Plug.Conn.t
  defp flash_messages(conn, messages) do
    Enum.reduce(messages, conn, fn message, conn ->
      put_flash(conn, :error, message)
    end)
  end
end
