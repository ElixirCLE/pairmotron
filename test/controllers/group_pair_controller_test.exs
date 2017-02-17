defmodule Pairmotron.GroupPairControllerTest do
  use Pairmotron.ConnCase

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

    test "cannot repairfy because user is not admin", %{conn: conn, group: group} do
      {year, week} = Timex.iso_week(Timex.today)
      conn = delete conn, group_pair_path(conn, :delete, group.id, year, week)
      refute Phoenix.Controller.get_flash(conn, :info) == "Repairified"
      assert redirected_to(conn) == group_pair_path(conn, :show, group.id, year, week)
    end
  end

  describe "while authenticated as admin" do
    setup do
      user = insert(:user, %{is_admin: true})
      group = insert(:group, %{owner: user, users: [user]})
      conn = build_conn() |> log_in(user)
      {:ok, [conn: conn, logged_in_user: user, group: group]}
    end

    test "can repairify", %{conn: conn, group: group} do
      {year, week} = Timex.iso_week(Timex.today)
      conn = delete conn, group_pair_path(conn, :delete, group.id, year, week)
      assert Phoenix.Controller.get_flash(conn, :info) == "Repairified"
      assert redirected_to(conn) == group_pair_path(conn, :show, group.id, year, week)
    end

    test "can repairify a non-member group", %{conn: conn} do
      {year, week} = Timex.iso_week(Timex.today)
      other_user = insert(:user)
      group = insert(:group, %{owner: other_user, users: [other_user]})
      conn = delete conn, group_pair_path(conn, :delete, group.id, year, week)
      assert Phoenix.Controller.get_flash(conn, :info) == "Repairified"
      assert redirected_to(conn) == group_pair_path(conn, :show, group.id, year, week)
    end

  end

  describe "while authenticated as a non-group user" do
    setup do
      user = insert(:user)
      user2 = insert(:user)
      group = insert(:group, %{owner: user2})
      Pairmotron.TestHelper.create_pair([user2], group)
      conn = build_conn() |> log_in(user)
      {:ok, [conn: conn, logged_in_user: user, group: group]}
    end

    test "cannot access group pairs", %{conn: conn, group: group} do
      conn = get conn, group_pair_path(conn, :show, group.id)
      assert redirected_to(conn) == pair_path(conn, :index)
    end

    test "cannot access group pairs for a specific period", %{conn: conn, group: group} do
      conn = get conn, group_pair_path(conn, :show, group.id, 2000, 1)
      assert redirected_to(conn) == pair_path(conn, :show, 2000, 1)
    end
  end
end
