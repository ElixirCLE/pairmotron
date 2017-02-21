defmodule Pairmotron.UsersGroupMembershipRequestControllerTest do
  use Pairmotron.ConnCase

  alias Pairmotron.{GroupMembershipRequest, UserGroup}

  import Pairmotron.TestHelper, only: [log_in: 2]

  test "redirects to sign-in when not logged in", %{conn: conn} do
    conn = get conn, users_group_membership_request_path(conn, :index)
    assert redirected_to(conn) == session_path(conn, :new)
  end

  describe "using :index while authenticated" do
    setup do
      user = insert(:user)
      conn = build_conn() |> log_in(user)
      {:ok, [conn: conn, logged_in_user: user]}
    end

    test "states that there are no active invitations when there are not", %{conn: conn} do
      conn = get conn, users_group_membership_request_path(conn, :index)
      assert html_response(conn, 200) =~ "You have no active invitations at this time"
    end

    test "user generated request displays on index properly", %{conn: conn, logged_in_user: user} do
      group = insert(:group)
      insert(:group_membership_request, %{initiated_by_user: true, user: user, group: group})
      conn = get conn, users_group_membership_request_path(conn, :index)

      assert html_response(conn, 200) =~ "User Requested"
      assert html_response(conn, 200) =~ "Awaiting Response"
      refute html_response(conn, 200) =~ "You have no active invitations at this time"
    end

    test "does not list other users invitations", %{conn: conn} do
      user = insert(:user)
      group = insert(:group)
      insert(:group_membership_request, %{initiated_by_user: true, user: user, group: group})

      conn = get conn, users_group_membership_request_path(conn, :index)
      assert html_response(conn, 200) =~ "You have no active invitations at this time"
    end

    test "group generated request displays on index properly", %{conn: conn, logged_in_user: user} do
      group = insert(:group)
      group_membership_request = insert(:group_membership_request, %{initiated_by_user: false, user: user, group: group})
      conn = get conn, users_group_membership_request_path(conn, :index)

      assert html_response(conn, 200) =~ "Invited by Group"
      assert html_response(conn, 200) =~ "Accept Invitation"
      assert html_response(conn, 200) =~ users_group_membership_request_path(conn, :update, group_membership_request)
      refute html_response(conn, 200) =~ "You have no active invitations at this time"
    end
  end

  describe "using :create while authenticated" do
    setup do
      user = insert(:user)
      conn = build_conn() |> log_in(user)
      {:ok, [conn: conn, logged_in_user: user]}
    end

    test "can create a group_membership_request", %{conn: conn, logged_in_user: user} do
      group = insert(:group)
      attrs = %{group_id: group.id}
      conn = post conn, users_group_membership_request_path(conn, :create), group_membership_request: attrs

      assert redirected_to(conn) == users_group_membership_request_path(conn, :index)
      assert Repo.get_by(GroupMembershipRequest, %{group_id: group.id, user_id: user.id, initiated_by_user: true})
    end

    test "cannot inject a different user into params", %{conn: conn, logged_in_user: user} do
      group = insert(:group)
      other_user = insert(:user)
      attrs = %{group_id: group.id, user_id: other_user.id}
      post conn, users_group_membership_request_path(conn, :create), group_membership_request: attrs

      assert Repo.get_by(GroupMembershipRequest, %{group_id: group.id, user_id: user.id, initiated_by_user: true})
      refute Repo.get_by(GroupMembershipRequest, %{group_id: group.id, user_id: other_user.id, initiated_by_user: true})
    end

    test "cannot inject initiated_by_user of false into params", %{conn: conn, logged_in_user: user} do
      group = insert(:group)
      attrs = %{group_id: group.id, initiated_by_user: false}
      post conn, users_group_membership_request_path(conn, :create), group_membership_request: attrs

      assert Repo.get_by(GroupMembershipRequest, %{group_id: group.id, user_id: user.id, initiated_by_user: true})
      refute Repo.get_by(GroupMembershipRequest, %{group_id: group.id, user_id: user.id, initiated_by_user: false})
    end

    test "errors without group_id param", %{conn: conn, logged_in_user: user} do
      post conn, users_group_membership_request_path(conn, :create), group_membership_request: %{}
      refute Repo.get_by(GroupMembershipRequest, %{user_id: user.id})
    end

    test "errors if user is already in group", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{users: [user]})
      attrs = %{group_id: group.id}
      post conn, users_group_membership_request_path(conn, :create), group_membership_request: attrs

      refute Repo.get_by(GroupMembershipRequest, %{group_id: group.id, user_id: user.id, initiated_by_user: true})
    end

    test "errors if a group_membership_request already exists for that user", %{conn: conn, logged_in_user: user} do
      group = insert(:group)
      attrs = %{group_id: group.id}
      insert(:group_membership_request, %{group: group, user: user, initiated_by_user: true})
      conn = post conn, users_group_membership_request_path(conn, :create), group_membership_request: attrs

      assert redirected_to(conn) == users_group_membership_request_path(conn, :index)
      assert 1 = Repo.all(GroupMembershipRequest) |> length
      assert %{private: %{phoenix_flash: %{"error" => _}}} = conn
    end
  end

  describe "using :update while authenticated" do
    setup do
      user = insert(:user)
      conn = build_conn() |> log_in(user)
      {:ok, [conn: conn, logged_in_user: user]}
    end

    test "creates a group and deletes group_invite if group_invite exists and created by group", %{conn: conn, logged_in_user: user} do
      group = insert(:group)
      group_membership_request = insert(:group_membership_request, %{group: group, user: user, initiated_by_user: false})
      conn = put conn, users_group_membership_request_path(conn, :update, group_membership_request), group_membership_request: %{}

      assert redirected_to(conn) == users_group_membership_request_path(conn, :index)
      refute Repo.get(GroupMembershipRequest, group_membership_request.id)
      assert Repo.get_by(UserGroup, %{group_id: group.id, user_id: user.id})
    end

    test "fails if group_membership_request doesn't exist", %{conn: conn, logged_in_user: user} do
      group = insert(:group)
      group_membership_request = build(:group_membership_request, %{group: group, user: user, initiated_by_user: false})
      group_membership_request = %{group_membership_request | id: 123} # otherwise id is nil

      conn = put conn, users_group_membership_request_path(conn, :update, group_membership_request), group_membership_request: %{}
      assert html_response(conn, 404) =~ "Page not found"
      refute Repo.get_by(UserGroup, %{group_id: group.id, user_id: user.id})
    end

    test "fails if logged in user is not in group_membership_request", %{conn: conn, logged_in_user: user} do
      group = insert(:group)
      other_user = insert(:user)
      group_membership_request = insert(:group_membership_request, %{group: group, user: other_user, initiated_by_user: false})
      conn = put conn, users_group_membership_request_path(conn, :update, group_membership_request), group_membership_request: %{}

      assert redirected_to(conn) == users_group_membership_request_path(conn, :index)
      assert Repo.get(GroupMembershipRequest, group_membership_request.id)
      refute Repo.get_by(UserGroup, %{group_id: group.id, user_id: user.id})
      refute Repo.get_by(UserGroup, %{group_id: group.id, user_id: other_user.id})
    end

    test "redirects and deletes group_membership_request if logged in user is already in the group", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{users: [user]})
      group_membership_request = insert(:group_membership_request, %{group: group, user: user, initiated_by_user: false})
      conn = put conn, users_group_membership_request_path(conn, :update, group_membership_request), group_membership_request: %{}

      assert redirected_to(conn) == users_group_membership_request_path(conn, :index)
      refute Repo.get(GroupMembershipRequest, group_membership_request.id)
    end

    test "fails if group_membership_request is created by user", %{conn: conn, logged_in_user: user} do
      group = insert(:group)
      group_membership_request = insert(:group_membership_request, %{group: group, user: user, initiated_by_user: true})
      conn = put conn, users_group_membership_request_path(conn, :update, group_membership_request), group_membership_request: %{}

      assert redirected_to(conn) == users_group_membership_request_path(conn, :index)
      assert Repo.get(GroupMembershipRequest, group_membership_request.id)
      refute Repo.get_by(UserGroup, %{group_id: group.id, user_id: user.id})
    end
  end
end
