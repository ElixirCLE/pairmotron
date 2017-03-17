defmodule Pairmotron.GroupInvitationControllerTest do
  use Pairmotron.ConnCase

  alias Pairmotron.UserGroup

  test "redirects to sign-in when not logged in", %{conn: conn} do
    group = insert(:group)
    user_group = insert(:user_group, %{group: group})
    conn = delete conn, user_group_path(conn, :delete, user_group)
    assert redirected_to(conn) == session_path(conn, :new)
  end

  describe "using :delete while authenticated" do
    setup do
      login_user()
    end

    test "deletes user group if logged in user is associated", %{conn: conn, logged_in_user: user} do
      group = insert(:group)
      user_group = insert(:user_group, %{group: group, user: user})

      conn = delete conn, user_group_path(conn, :delete, user_group)
      assert redirected_to(conn) == profile_path(conn, :show)
      refute Repo.get(UserGroup, user_group.id)
    end

    test "deletes user group if logged in user owns the associated group", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user})
      user_group = insert(:user_group, %{group: group})

      conn = delete conn, user_group_path(conn, :delete, user_group)
      assert redirected_to(conn) == group_path(conn, :show, group)
      refute Repo.get(UserGroup, user_group.id)
    end

    test "deletes user group and redirects to profile user is owner of group and the user on the user_group",
      %{conn: conn, logged_in_user: user} do

      group = insert(:group, %{owner: user})
      user_group = insert(:user_group, %{group: group, user: user})

      conn = delete conn, user_group_path(conn, :delete, user_group)
      assert redirected_to(conn) == profile_path(conn, :show)
      refute Repo.get(UserGroup, user_group.id)
    end

    test "fails if logged in user is not associated with user group", %{conn: conn} do
      group = insert(:group)
      user_group = insert(:user_group, %{group: group})

      conn = delete conn, user_group_path(conn, :delete, user_group)
      assert redirected_to(conn) == group_path(conn, :show, group)
      assert Repo.get(UserGroup, user_group.id)
    end
  end
end
