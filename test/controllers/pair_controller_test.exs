defmodule Pairmotron.PairControllerTest do
  use Pairmotron.ConnCase

  import Pairmotron.TestHelper,
    only: [log_in: 2]

  describe "while authenticated and not belonging to any groups" do
    setup do
      login_user()
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
      pair = insert(:pair, group: group, users: [user, other_user])
      insert(:retro, %{pair: pair, user: other_user})
      conn = get(conn, "/pairs")
      assert html_response(conn, 200) =~ pair_retro_path(conn, :new, pair.id)
    end

    test "displays link to retro :show for pair and current user with retrospective",
      %{conn: conn, logged_in_user: user, group: group} do
      pair = insert(:pair, %{group: group, users: [user]})
      retro = insert(:retro, %{user: user, pair: pair})
      conn = get(conn, "/pairs")
      assert html_response(conn, 200) =~ pair_retro_path(conn, :show, retro.id)
    end

    test "displays link to retro :show for pair and current user with retrospective for :show",
      %{conn: conn, logged_in_user: user, group: group} do
      {year, week} = Timex.iso_week(Timex.today)
      pair = insert(:pair, %{group: group, users: [user], year: year, week: week})
      retro = insert(:retro, %{user: user, pair: pair})

      conn = get conn, pair_path(conn, :show, year, week)
      assert html_response(conn, 200) =~ pair_retro_path(conn, :show, retro.id)
    end

    test "does not display pairs in user's group that the user is not in", %{conn: conn, logged_in_user: user, group: group} do
      other_user_in_pair = insert(:user, %{groups: [group]})
      other_user_not_in_pair = insert(:user, %{groups: [group]})
      insert(:pair, %{group: group, users: [user, other_user_in_pair]})
      insert(:pair, %{group: group, users: [other_user_not_in_pair]})

      conn = get conn, pair_path(conn, :index)
      assert html_response(conn, 200) =~ other_user_in_pair.name
      refute html_response(conn, 200) =~ other_user_not_in_pair.name
    end
  end

  describe "when authenticated and in two groups" do
    setup do
      user = insert(:user)
      group1 = insert(:group, %{owner: user, users: [user]})
      group2 = insert(:group, %{owner: user, users: [user]})
      conn = build_conn() |> log_in(user)
      {:ok, [conn: conn, logged_in_user: user, groups: [group1, group2]]}
    end

    test "lists both groups", %{conn: conn, logged_in_user: user, groups: groups} do
      [group1, group2] = groups
      insert(:pair, %{group: group1, users: [user]})
      insert(:pair, %{group: group2, users: [user]})

      conn = get conn, pair_path(conn, :index)
      assert html_response(conn, 200) =~ group1.name
      assert html_response(conn, 200) =~ group2.name
    end

    test "lists other users in both pairs", %{conn: conn, logged_in_user: user, groups: groups} do
      [group1, group2] = groups
      user2 = insert(:user)
      user3 = insert(:user)
      insert(:pair, %{group: group1, users: [user, user2]})
      insert(:pair, %{group: group2, users: [user, user3]})

      conn = get conn, pair_path(conn, :index)
      assert html_response(conn, 200) =~ user2.name
      assert html_response(conn, 200) =~ user3.name
    end

    test "has links to create retros for both pairs if they do not exist", %{conn: conn, logged_in_user: user, groups: groups} do
      [group1, group2] = groups
      pair1 = insert(:pair, %{group: group1, users: [user]})
      pair2 = insert(:pair, %{group: group2, users: [user]})

      conn = get conn, pair_path(conn, :index)
      assert html_response(conn, 200) =~ pair_retro_path(conn, :new, pair1.id)
      assert html_response(conn, 200) =~ pair_retro_path(conn, :new, pair2.id)
    end

    test "links to edit retro for one group when it exists and create for the other that does not exist",
      %{conn: conn, logged_in_user: user, groups: groups} do
      [group1, group2] = groups
      pair1 = insert(:pair, %{group: group1, users: [user]})
      pair2 = insert(:pair, %{group: group2, users: [user]})
      retro2 = insert(:retro, %{pair: pair2, user: user})

      conn = get conn, pair_path(conn, :index)
      assert html_response(conn, 200) =~ pair_retro_path(conn, :new, pair1.id)
      assert html_response(conn, 200) =~ pair_retro_path(conn, :edit, retro2.id)
    end

    test "links to edit retro for both exists if both retros exist", %{conn: conn, logged_in_user: user, groups: groups} do
      [group1, group2] = groups
      pair1 = insert(:pair, %{group: group1, users: [user]})
      pair2 = insert(:pair, %{group: group2, users: [user]})
      retro1 = insert(:retro, %{pair: pair1, user: user})
      retro2 = insert(:retro, %{pair: pair2, user: user})

      conn = get conn, pair_path(conn, :index)
      assert html_response(conn, 200) =~ pair_retro_path(conn, :edit, retro1.id)
      assert html_response(conn, 200) =~ pair_retro_path(conn, :edit, retro2.id)
    end
  end
end
