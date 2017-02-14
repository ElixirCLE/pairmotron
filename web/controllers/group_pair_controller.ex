defmodule Pairmotron.GroupPairController do
  use Pairmotron.Web, :controller

  import Pairmotron.ControllerHelpers
  alias Pairmotron.PairMaker

  def index(conn, %{"group_id" => g}) do
    {year, week} = Timex.iso_week(Timex.today)
    {group_id, _} = g |> Integer.parse
    pairs = PairMaker.fetch_or_gen(year, week, group_id)
    conn = assign_current_user_pair_retro_for_week(conn, year, week)
    render conn, "index.html", pairs: pairs, year: year, week: week, group_id: group_id
  end

  def show(conn, %{"year" => y, "week" => w, "group_id" => g}) do
    {year, _} = y |> Integer.parse
    {week, _} = w |> Integer.parse
    {group_id, _} = g |> Integer.parse
    pairs = PairMaker.fetch_or_gen(year, week, group_id)
    conn = assign_current_user_pair_retro_for_week(conn, year, week)
    render conn, "index.html", pairs: pairs, year: year, week: week, group_id: group_id
  end

  def delete(conn, %{"year" => y, "week" => w, "group_id" => g}) do
    if conn.assigns.current_user.is_admin do
      {year, _} = y |> Integer.parse
      {week, _} = w |> Integer.parse
      {group_id, _} = g |> Integer.parse
      PairMaker.generate_pairs(year, week, group_id)
      conn
        |> put_flash(:info, "Repairified")
        |> redirect(to: group_pair_path(conn, :show, group_id, year, week))
    else
      redirect_not_authorized(conn, profile_path(conn, :show))
    end
  end
end
