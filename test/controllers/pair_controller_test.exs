defmodule Pairmotron.PairControllerTest do
  use Pairmotron.ConnCase

  import Pairmotron.TestHelper,
    only: [log_in: 2, create_retro: 2, create_pair_and_retro: 2]

  describe "while authenticated and not belonging to any groups" do
    setup do
      user = insert(:user)
      conn = build_conn() |> log_in(user)
      {:ok, [conn: conn, logged_in_user: user]}
    end

    test "displays helpful message when there are no groups", %{conn: conn} do
      conn = get(conn, "/pairs")
      assert html_response(conn, 200) =~ "Find a group"
    end
  end

  describe "while authenticated and belonging to a group" do
    setup do
      user = insert(:user)
      group = insert(:group, %{owner: user, users: [user]})
      conn = build_conn() |> log_in(user)
      {:ok, [conn: conn, logged_in_user: user, group: group]}
    end

    test "displays the correct date range on the page", %{conn: conn} do
      conn = get conn, pair_path(conn, :show, 1999, 52)
      assert html_response(conn, 200) =~ "1999-12-27 to 2000-01-02"
    end

    test "displays helpful message when there are no pairs", %{conn: conn} do
      conn = get conn, pair_path(conn, :show, 2000, 1)
      assert html_response(conn, 200) =~ "No pairs"
    end

    test "displays link to retro :create for a pair and current user with no retrospective",
      %{conn: conn, logged_in_user: user, group: group} do
      pair = Pairmotron.TestHelper.create_pair([user], group)
      conn = get(conn, "/pairs")
      assert html_response(conn, 200) =~ pair_retro_path(conn, :new, pair.id)
    end

    test "displays link to retro :create when the other user in pair has retro but current_user doesn't",
      %{conn: conn, logged_in_user: user, group: group} do
      other_user = insert(:user)
      pair = Pairmotron.TestHelper.create_pair([user, other_user], group)
      create_retro(other_user, pair)
      conn = get(conn, "/pairs")
      assert html_response(conn, 200) =~ pair_retro_path(conn, :new, pair.id)
    end

    test "displays link to retro :show for pair and current user with retrospective",
      %{conn: conn, logged_in_user: user, group: group} do
      {_pair, retro} = create_pair_and_retro(user, group)
      conn = get(conn, "/pairs")
      assert html_response(conn, 200) =~ pair_retro_path(conn, :show, retro.id)
    end

    test "displays link to retro :show for pair and current user with retrospective for :show",
      %{conn: conn, logged_in_user: user, group: group} do
      {year, week} = Timex.iso_week(Timex.today)
      pair = Pairmotron.TestHelper.create_pair([user], group, year, week)
      retro = create_retro(user, pair) # create_retro function defines pair_date as Timex.today
      conn = get conn, pair_path(conn, :show, year, week)
      assert html_response(conn, 200) =~ pair_retro_path(conn, :show, retro.id)
    end

    test "displays each of the user's groups' pairs (only the pairs including the user)", %{conn: conn, logged_in_user: user, group: group} do
      {year, week} = Timex.iso_week(Timex.today)
      user2 = insert(:user)
      user3 = insert(:user)
      group2 = insert(:group, %{owner: user, users: [user, user2, user3]})
      Pairmotron.TestHelper.create_pair([user], group, year, week)
      Pairmotron.TestHelper.create_pair([user, user2], group2, year, week)
      Pairmotron.TestHelper.create_pair([user3], group2, year, week)
      conn = get conn, pair_path(conn, :index)
      assert html_response(conn, 200) =~ group.name
      assert html_response(conn, 200) =~ group2.name
      refute html_response(conn, 200) =~ user3.name
    end
  end
end
