defmodule Pairmotron.GroupPairController do
  @moduledoc """
  Handles displaying all of the pairs associated with a year and week for a
  specific group.
  """
  use Pairmotron.Web, :controller

  import Pairmotron.ControllerHelpers
  alias Pairmotron.{PairMaker, Group}

  @spec show(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def show(conn, %{"year" => y, "week" => w, "id" => g}) do
    {year, _} = y |> Integer.parse
    {week, _} = w |> Integer.parse
    {group_id, _} = g |> Integer.parse

    group = Repo.get(Group, group_id)
    if authorized?(group, conn.assigns.current_user) do
      {conn, pairs} = fetch_pairs(conn, year, week, group_id)
      conn = assign_current_user_pair_retro_for_week(conn, year, week)
      render conn, "index.html", pairs: pairs, year: year, week: week, group: group,
        start_date: Timex.from_iso_triplet({year, week, 1}),
        stop_date: Timex.from_iso_triplet({year, week, 7})
    else
      redirect_not_authorized(conn, pair_path(conn, :show, y, w))
    end
  end
  def show(conn, %{"id" => g}) do
    {year, week} = Timex.iso_week(Timex.today)
    show(conn, %{"id" => g, "year" => year |> Integer.to_string, "week" => week |> Integer.to_string})
  end

  @spec delete(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def delete(conn, %{"year" => y, "week" => w, "id" => g}) do
    if conn.assigns.current_user.is_admin do
      {year, _} = y |> Integer.parse
      {week, _} = w |> Integer.parse
      {group_id, _} = g |> Integer.parse
      conn
        |> generate_pairs(year, week, group_id)
        |> redirect(to: group_pair_path(conn, :show, group_id, year, week))
    else
      redirect_not_authorized(conn, group_pair_path(conn, :show, g, y, w))
    end
  end

  defp authorized?(group, user) do
    group = group |> Pairmotron.Repo.preload(:users)
    group.users
      |> Enum.any?(fn guser -> guser.id == user.id end)
  end

  defp fetch_pairs(conn, year, week, group_id) do
    case PairMaker.fetch_or_gen(year, week, group_id) do
      {:error, pairs, message} ->
        {conn |> put_flash(:error, message), pairs}
      {:ok, pairs, _} ->
        {conn, pairs}
    end
  end

  defp generate_pairs(conn, year, week, group_id) do
    case PairMaker.generate_pairs(year, week, group_id) do
      {:error, message} ->
        conn |> put_flash(:error, message)
      {:ok, _} ->
        conn |> put_flash(:info, "Repairified")
    end
  end
end
