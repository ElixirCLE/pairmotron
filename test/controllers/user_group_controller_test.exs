defmodule Pairmotron.UserGroupControllerTest do
  use Pairmotron.ConnCase

  alias Pairmotron.UserGroup

  test "redirects to sign-in when not logged in", %{conn: conn} do
    group = insert(:group)
    other_user = insert(:user)
    insert(:user_group, %{group: group, user: other_user})
    conn = delete conn, user_group_path(conn, :delete, group, other_user)
    assert redirected_to(conn) == session_path(conn, :new)
  end

  describe "using :edit while authenticated" do
    setup do
      login_user()
    end

    test "renders form for editing UserGroup if user is owner of group", %{conn: conn, logged_in_user: user} do
      other_user = insert(:user)
      group = insert(:group, %{owner: user, users: [user, other_user]})
      conn = get conn, user_group_path(conn, :edit, group, other_user)
      assert html_response(conn, 200) =~ "Edit #{other_user.name}&#39;s membership in #{group.name}"
    end

    test "renders form for editing UserGroup is user is admin in group", %{conn: conn, logged_in_user: user} do
      other_user = insert(:user)
      group = insert(:group, %{users: [other_user]})
      insert(:user_group, %{user: user, group: group, is_admin: true})
      conn = get conn, user_group_path(conn, :edit, group, other_user)
      assert html_response(conn, 200) =~ "Edit #{other_user.name}&#39;s membership in #{group.name}"
    end

    test "rendered form has link to remove user from group", %{conn: conn, logged_in_user: user} do
      other_user = insert(:user)
      group = insert(:group, %{owner: user, users: [user, other_user]})
      conn = get conn, user_group_path(conn, :edit, group, other_user)
      assert html_response(conn, 200) =~ "Remove from group"
    end

    test "fails if user is not oner or admin of group", %{conn: conn, logged_in_user: user} do
      other_user = insert(:user)
      group = insert(:group, %{users: [user, other_user]})
      conn = get conn, user_group_path(conn, :edit, group, other_user)
      assert redirected_to(conn) == group_path(conn, :show, group)
    end

    test "fails if logged in user is not in group", %{conn: conn} do
      other_user = insert(:user)
      group = insert(:group, %{users: [other_user]})
      conn = get conn, user_group_path(conn, :edit, group, other_user)
      assert redirected_to(conn) == group_path(conn, :show, group)
    end

    test "fails if user to be edited is not in group", %{conn: conn, logged_in_user: user} do
      other_user = insert(:user)
      group = insert(:group, %{owner: user, users: [user]})
      conn = get conn, user_group_path(conn, :edit, group, other_user)
      assert redirected_to(conn) == group_path(conn, :show, group)
    end

    test "fails if group in route does not exist", %{conn: conn, logged_in_user: user} do
      conn = get conn, user_group_path(conn, :edit, 123, user)
      assert redirected_to(conn) == group_path(conn, :show, 123)
    end

    test "fails is user in route does not exist", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      conn = get conn, user_group_path(conn, :edit, group, 123)
      assert redirected_to(conn) == group_path(conn, :show, group)
    end
  end

  describe "using :delete while authenticated" do
    setup do
      login_user()
    end

    test "deletes user group if logged in user is associated", %{conn: conn, logged_in_user: user} do
      group = insert(:group)
      user_group = insert(:user_group, %{group: group, user: user})

      conn = delete conn, user_group_path(conn, :delete, group, user)
      assert redirected_to(conn) == profile_path(conn, :show)
      refute Repo.get(UserGroup, user_group.id)
    end

    test "deletes user group if logged in user owns the associated group", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user})
      other_user = insert(:user)
      user_group = insert(:user_group, %{group: group, user: other_user})

      conn = delete conn, user_group_path(conn, :delete, group, other_user)
      assert redirected_to(conn) == group_path(conn, :show, group)
      refute Repo.get(UserGroup, user_group.id)
    end

    test "deletes user group and redirects to profile user is owner of group and the user on the user_group",
      %{conn: conn, logged_in_user: user} do

      group = insert(:group, %{owner: user})
      user_group = insert(:user_group, %{group: group, user: user})

      conn = delete conn, user_group_path(conn, :delete, group, user)
      assert redirected_to(conn) == profile_path(conn, :show)
      refute Repo.get(UserGroup, user_group.id)
    end

    test "fails if logged in user is not associated with user group", %{conn: conn} do
      group = insert(:group)
      other_user = insert(:user)
      user_group = insert(:user_group, %{group: group, user: other_user})

      conn = delete conn, user_group_path(conn, :delete, group, other_user)
      assert redirected_to(conn) == group_path(conn, :show, group)
      assert Repo.get(UserGroup, user_group.id)
    end

    test "fails and redirects if user in route doesn't exist", %{conn: conn} do
      group = insert(:group)
      conn = delete conn, user_group_path(conn, :delete, group, 123)
      assert redirected_to(conn) == pair_path(conn, :index)
    end

    test "fails and redirects if group in route doesn't exist", %{conn: conn} do
      other_user = insert(:user)
      conn = delete conn, user_group_path(conn, :delete, 123, other_user)
      assert redirected_to(conn) == pair_path(conn, :index)
    end

    test "fails and redirects if specified user is not in group", %{conn: conn} do
      group = insert(:group)
      other_user = insert(:user)
      conn = delete conn, user_group_path(conn, :delete, group, other_user)
      assert redirected_to(conn) == pair_path(conn, :index)
    end
  end
end
