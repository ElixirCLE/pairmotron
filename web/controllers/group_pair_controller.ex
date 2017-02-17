defmodule Pairmotron.GroupPairController do
  use Pairmotron.Web, :controller

  import Pairmotron.ControllerHelpers
  alias Pairmotron.{PairMaker, Group}

  def show(conn, %{"year" => y, "week" => w, "id" => g}) do
    {year, _} = y |> Integer.parse
    {week, _} = w |> Integer.parse
    {group_id, _} = g |> Integer.parse

    group = Repo.get(Group, group_id)
    if authorized?(group, conn.assigns.current_user) do
      pairs = PairMaker.fetch_or_gen(year, week, group_id)
      conn = assign_current_user_pair_retro_for_week(conn, year, week)
      render conn, "index.html", pairs: pairs, year: year, week: week, group: group
    else
      redirect_not_authorized(conn, pair_path(conn, :show, y, w))
    end
  end
  def show(conn, %{"id" => g}) do
    {year, week} = Timex.iso_week(Timex.today)
    show(conn, %{"id" => g, "year" => year |> Integer.to_string, "week" => week |> Integer.to_string})
  end

  def delete(conn, %{"year" => y, "week" => w, "id" => g}) do
    if conn.assigns.current_user.is_admin do
      {year, _} = y |> Integer.parse
      {week, _} = w |> Integer.parse
      {group_id, _} = g |> Integer.parse
      PairMaker.generate_pairs(year, week, group_id)
      conn
        |> put_flash(:info, "Repairified")
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
end
