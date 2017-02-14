defmodule Pairmotron.GroupPairControllerTest do
  use Pairmotron.ConnCase

  alias Pairmotron.{UserPair, User, Pair}
  import Pairmotron.TestHelper,
    only: [log_in: 2, create_retro: 2, create_pair_and_retro: 2]

  describe "while authenticated" do
    setup do
      user = insert(:user)
      group = insert(:group, %{owner: user, users: [user]})
      conn = build_conn() |> log_in(user)
      {:ok, [conn: conn, logged_in_user: user, group: group]}
    end

    test "lists one active user", %{conn: conn, logged_in_user: user, group: group} do
      conn = get(conn, "/groups/#{group.id}/pairs")
      assert html_response(conn, 200) =~ user.name
    end

    test "does not list an inactive user", %{conn: conn, group: group} do
      user = insert(:user, active: false)
      conn = get(conn, "/groups/#{group.id}/pairs")
      refute html_response(conn, 200) =~ user.name
    end

    test "pairs two users together", %{conn: conn, logged_in_user: user1} do
      user2 = insert(:user)
      group = insert(:group, %{users: [user1, user2]})
      conn = get(conn, "/groups/#{group.id}/pairs")
      assert html_response(conn, 200) =~ user1.name
      assert html_response(conn, 200) =~ user2.name
    end

    test "displays link to retro :create for a pair and current user with no retrospective",
      %{conn: conn, logged_in_user: user, group: group} do
      pair = Pairmotron.TestHelper.create_pair([user], group)
      conn = get(conn, "/groups/#{group.id}/pairs")
      assert html_response(conn, 200) =~ pair_retro_path(conn, :new, pair.id)
    end

    test "displays link to retro :create when the other user in pair has retro but current_user doesn't",
      %{conn: conn, logged_in_user: user, group: group} do
      other_user = insert(:user)
      pair = Pairmotron.TestHelper.create_pair([user, other_user], group)
      create_retro(other_user, pair)
      conn = get(conn, "/groups/#{group.id}/pairs")
      assert html_response(conn, 200) =~ pair_retro_path(conn, :new, pair.id)
    end

    test "displays link to retro :show for pair and current user with retrospective",
      %{conn: conn, logged_in_user: user, group: group} do
      {_pair, retro} = create_pair_and_retro(user, group)
      conn = get(conn, "/groups/#{group.id}/pairs")
      assert html_response(conn, 200) =~ pair_retro_path(conn, :show, retro.id)
    end

    test "displays link to retro :show for pair and current user with retrospective for :show",
      %{conn: conn, logged_in_user: user, group: group} do
      {year, week} = Timex.iso_week(Timex.today)
      pair = Pairmotron.TestHelper.create_pair([user], group, year, week)
      retro = create_retro(user, pair) # create_retro function defines pair_date as Timex.today
      conn = get conn, group_pair_path(conn, :show, group.id, year, week)
      assert html_response(conn, 200) =~ pair_retro_path(conn, :show, retro.id)
    end

    test "does not re-pair after the first pair has been made", %{conn: conn, logged_in_user: user, group: group} do
      Pairmotron.TestHelper.create_pair([user], group)
      new_user = insert(:user)
      conn = get(conn, "/groups/#{group.id}/pairs")
      assert html_response(conn, 200) =~ user.name
      refute html_response(conn, 200) =~ new_user.name
    end

    test "does not pairify for a week that is not current", %{conn: conn, logged_in_user: user, group: group} do
      conn = get conn, group_pair_path(conn, :show, group.id, 1999, 1)
      refute html_response(conn, 200) =~ user.name
    end

    test "cannot repairfy because user is not admin", %{conn: conn, logged_in_user: user, group: group} do
      {year, week} = Timex.iso_week(Timex.today)
      Pairmotron.TestHelper.create_pair([user], group)
      conn = delete conn, group_pair_path(conn, :delete, group.id, year, week)
      assert redirected_to(conn) == profile_path(conn, :show)
      assert Repo.get_by(UserPair, %{user_id: user.id})
    end
  end

  describe "while authenticated as admin" do
    setup do
      user = insert(:user, %{is_admin: true})
      group = insert(:group, %{owner: user, users: [user]})
      conn = build_conn() |> log_in(user)
      {:ok, [conn: conn, logged_in_user: user, group: group]}
    end

    test "can repairify", %{conn: conn, logged_in_user: user, group: group} do
      {year, week} = Timex.iso_week(Timex.today)
      user2 = insert(:user)
      Pairmotron.TestHelper.create_pair([user, user2], group)
      Repo.update! User.changeset(user2, %{active: false})
      conn = delete conn, group_pair_path(conn, :delete, group.id, year, week)
      assert redirected_to(conn) == group_pair_path(conn, :show, group.id, year, week)
      refute Repo.get_by(UserPair, %{user_id: user2.id})
    end

    test "repairifying deletes invalid pairs and redirects to show", %{conn: conn, logged_in_user: user, group: group} do
      {year, week} = Timex.iso_week(Timex.today)
      user2 = insert(:user)
      Pairmotron.TestHelper.create_pair([user, user2], group)
      Repo.update! User.changeset(user2, %{active: false})
      conn = delete conn, group_pair_path(conn, :delete, group.id, year, week)
      assert redirected_to(conn) == group_pair_path(conn, :show, group.id, year, week)
      refute Repo.get_by(UserPair, %{user_id: user2.id})
    end

    test "repairifying does not affect retro'd pairs", %{conn: conn, logged_in_user: user, group: group} do
      {year, week} = Timex.iso_week(Timex.today)
      user2 = insert(:user)
      pair = Pairmotron.TestHelper.create_pair([user, user2], group)
      create_retro(user, pair)
      user3 = insert(:user)
      delete conn, group_pair_path(conn, :delete, group.id, year, week)
      refute Repo.get_by(UserPair, %{user_id: user3.id, pair_id: pair.id})
    end

    test "repairifying does not delete valid pairs", %{conn: conn, logged_in_user: user} do
      {year, week} = Timex.iso_week(Timex.today)
      user2 = insert(:user)
      group = insert(:group, %{users: [user, user2]})
      pair = Pairmotron.TestHelper.create_pair([user, user2], group)
      delete conn, group_pair_path(conn, :delete, group.id, year, week)
      assert Repo.get(Pair, pair.id)
    end
  end
end
