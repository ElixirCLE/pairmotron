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
    {groups_and_pairs, messages} = fetch_groups_and_pairs(year, week, user)

    conn
    |> flash_messages(messages)
    |> render("index.html", year: year, week: week, groups_and_pairs: groups_and_pairs,
                start_date: Timex.from_iso_triplet({year, week, 1}),
                stop_date: Timex.from_iso_triplet({year, week, 7}))
  end

  @spec show(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def show(conn, %{"year" => y, "week" => w}) do
    {year, _} = y |> Integer.parse
    {week, _} = w |> Integer.parse
    user = conn.assigns[:current_user]
    {groups_and_pairs, messages} = fetch_groups_and_pairs(year, week, user)

    conn
    |> flash_messages(messages)
    |> render("index.html", year: year, week: week, groups_and_pairs: groups_and_pairs,
                start_date: Timex.from_iso_triplet({year, week, 1}),
                stop_date: Timex.from_iso_triplet({year, week, 7}))
  end

  @spec fetch_groups_and_pairs(integer(), 1..53, Types.user) :: {[{Types.group, Types.pair}], [String.t]}
  defp fetch_groups_and_pairs(year, week, user) do
    user = user |> Repo.preload(:groups)
    {pairs, messages} = pairs_for_user_groups(user, year, week)
    {Enum.zip(user.groups, pairs), messages}
  end

  @spec pairs_for_user_groups(Types.user, integer(), 1..53) :: {[Types.pair], [String.t]}
  defp pairs_for_user_groups(user, year, week) do
    Enum.reduce(user.groups, {[], []},
      fn(group, pairs_and_messages) ->
        {result_pairs, messages} = pairs_and_messages
        case PairMaker.fetch_or_gen(year, week, group.id) do
          {:error, pairs, message} ->
            {result_pairs ++ [pairs |> pairs_containing_user(user)], [message | messages]}
          {:ok, pairs} ->
            {result_pairs ++ [pairs |> pairs_containing_user(user)], [messages]}
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
