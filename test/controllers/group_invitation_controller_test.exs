defmodule Pairmotron.GroupInvitationControllerTest do
  use Pairmotron.ConnCase

  alias Pairmotron.{GroupMembershipRequest, UserGroup}

  import Pairmotron.TestHelper, only: [log_in: 2]

  test "redirects to sign-in when not logged in", %{conn: conn} do
    group = insert(:group)
    conn = get conn, group_invitation_path(conn, :index, group)
    assert redirected_to(conn) == session_path(conn, :new)
  end

  describe "using :index while authenticated" do
    setup do
      user = insert(:user)
      conn = build_conn() |> log_in(user)
      group = insert(:group, %{owner: user, users: [user]})
      {:ok, [conn: conn, logged_in_user: user, group: group]}
    end

    test "states that there are no active group invitations when there are not", %{conn: conn, group: group} do
      conn = get conn, group_invitation_path(conn, :index, group)
      assert html_response(conn, 200) =~ "There are no active invitations for this group at this time"
    end

    test "lists an invitation that is associated with the group", %{conn: conn, group: group} do
      user = insert(:user)
      insert(:group_membership_request, %{user: user, group: group, initiated_by_user: false})
      conn = get conn, group_invitation_path(conn, :index, group)
      assert html_response(conn, 200) =~ user.name
      assert html_response(conn, 200) =~ "Awaiting Response"
    end

    test "lists an invitation initiated by user and links to accept the invitation", %{conn: conn, group: group} do
      user = insert(:user)
      group_membership_request = insert(:group_membership_request, %{user: user, group: group, initiated_by_user: true})
      conn = get conn, group_invitation_path(conn, :index, group)
      assert html_response(conn, 200) =~ user.name
      assert html_response(conn, 200) =~ "Accept Membership Request"
      assert html_response(conn, 200) =~ group_invitation_path(conn, :update, group.id, group_membership_request)
    end

    test "does not list invitations not associated with the group", %{conn: conn, group: group} do
      user = insert(:user)
      other_group = insert(:group)
      insert(:group_membership_request, %{user: user, group: other_group, initiated_by_user: false})
      conn = get conn, group_invitation_path(conn, :index, group)
      assert html_response(conn, 200) =~ "There are no active invitations for this group at this time"
    end

    test "does not list invitations if user is not owner of group", %{conn: conn} do
      group = insert(:group)
      conn = get conn, group_invitation_path(conn, :index, group)
      assert redirected_to(conn) == group_path(conn, :show, group)
    end

    test "handles nonexistent group", %{conn: conn} do
      conn = get conn, group_invitation_path(conn, :index, 1)
      assert html_response(conn, 404) =~ "not found"
    end
  end

  describe "using :new while authenticated" do
    setup do
      login_user()
    end

    test "renders invitation form if user is owner of group", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      conn = get conn, group_invitation_path(conn, :new, group)
      assert html_response(conn, 200) =~ "Invite user to"
      assert html_response(conn, 200) =~ group.name
    end

    test "form can select user who is not in group", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      other_user = insert(:user)
      conn = get conn, group_invitation_path(conn, :new, group)
      assert html_response(conn, 200) =~ other_user.name
    end

    test "form cannot select user who is already in group", %{conn: conn, logged_in_user: user} do
      other_user = insert(:user)
      group = insert(:group, %{owner: user, users: [user, other_user]})
      conn = get conn, group_invitation_path(conn, :new, group)
      refute html_response(conn, 200) =~ other_user.name
    end

    test "redirects if logged in user in group but not owner of group", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{users: [user]})
      conn = get conn, group_invitation_path(conn, :new, group)
      assert redirected_to(conn) == group_invitation_path(conn, :index, group)
    end

    test "redirects if logged in user is not owner of group", %{conn: conn} do
      group = insert(:group)
      conn = get conn, group_invitation_path(conn, :new, group)
      assert redirected_to(conn) == group_invitation_path(conn, :index, group)
    end
  end

  describe "using :create while authenticated" do
    setup do
      login_user()
    end

    test "can create a group_membership_request if current_user is owner of group", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      other_user = insert(:user)
      attrs = %{user_id: other_user.id}
      conn = post conn, group_invitation_path(conn, :create, group), group_membership_request: attrs

      assert redirected_to(conn) == group_invitation_path(conn, :index, group)
      assert Repo.get_by(GroupMembershipRequest, %{group_id: group.id, user_id: other_user.id, initiated_by_user: false})
    end

    test "cannot create a group_membership_request if current_user is not in group", %{conn: conn} do
      group = insert(:group)
      other_user = insert(:user)
      attrs = %{user_id: other_user.id}
      conn = post conn, group_invitation_path(conn, :create, group), group_membership_request: attrs

      assert redirected_to(conn) == group_invitation_path(conn, :index, group)
      refute Repo.get_by(GroupMembershipRequest, %{group_id: group.id, user_id: other_user.id})
    end

    test "cannot create a group_membership_request if current_user is in group but not owner", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{users: [user]})
      other_user = insert(:user)
      attrs = %{user_id: other_user.id}
      conn = post conn, group_invitation_path(conn, :create, group), group_membership_request: attrs

      assert redirected_to(conn) == group_invitation_path(conn, :index, group)
      refute Repo.get_by(GroupMembershipRequest, %{group_id: group.id, user_id: other_user.id})
    end

    test "cannot inject a different group into the params", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      other_group = insert(:group)
      other_user = insert(:user)
      attrs = %{user_id: other_user.id, group_id: other_group.id}
      conn = post conn, group_invitation_path(conn, :create, group), group_membership_request: attrs

      assert redirected_to(conn) == group_invitation_path(conn, :index, group)
      assert Repo.get_by(GroupMembershipRequest, %{group_id: group.id, user_id: other_user.id, initiated_by_user: false})
      refute Repo.get_by(GroupMembershipRequest, %{group_id: other_group.id, user_id: other_user.id})
    end

    test "cannot inject different initiated_by_user into params", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      other_user = insert(:user)
      attrs = %{user_id: other_user.id, initiated_by_user: true}
      conn = post conn, group_invitation_path(conn, :create, group), group_membership_request: attrs

      assert redirected_to(conn) == group_invitation_path(conn, :index, group)
      assert Repo.get_by(GroupMembershipRequest, %{group_id: group.id, user_id: other_user.id, initiated_by_user: false})
      refute Repo.get_by(GroupMembershipRequest, %{group_id: group.id, user_id: other_user.id, initiated_by_user: true})
    end

    test "cannot invite user that is already in the group", %{conn: conn, logged_in_user: user} do
      other_user = insert(:user)
      group = insert(:group, %{owner: user, users: [user, other_user]})
      attrs = %{user_id: other_user.id}
      conn = post conn, group_invitation_path(conn, :create, group), group_membership_request: attrs

      assert html_response(conn, 200) =~ "User is already in this group"
      refute Repo.get_by(GroupMembershipRequest, %{group_id: group.id, user_id: other_user.id})
    end

    test "cannot invite user that already has an active invite", %{conn: conn, logged_in_user: user} do
      other_user = insert(:user)
      group = insert(:group, %{owner: user, users: [user]})
      insert(:group_membership_request, %{group_id: group.id, user_id: other_user.id, initiated_by_user: false})
      attrs = %{user_id: other_user.id}
      conn = post conn, group_invitation_path(conn, :create, group), group_membership_request: attrs

      assert html_response(conn, 200) =~ "User is already invited to this group"
      assert 1 = Repo.all(GroupMembershipRequest) |> length
    end
  end

  describe "using :update while authenticated" do
    setup do
      login_user()
    end

    test "creates a group and deletes group_invite if group_invite exists and created by user", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      other_user = insert(:user)
      group_membership_request = insert(:group_membership_request, %{group: group, user: other_user, initiated_by_user: true})
      conn = put conn, group_invitation_path(conn, :update, group, group_membership_request), group_membership_request: %{}

      assert redirected_to(conn) == group_invitation_path(conn, :index, group)
      refute Repo.get(GroupMembershipRequest, group_membership_request.id)
      assert Repo.get_by(UserGroup, %{group_id: group.id, user_id: other_user.id})
    end

    test "fails if group_membership_request doesn't exist", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      other_user = insert(:user)
      group_membership_request = build(:group_membership_request, %{group: group, user: other_user, initiated_by_user: false})
      group_membership_request = %{group_membership_request | id: 123} # otherwise id is nil
      conn = put conn, group_invitation_path(conn, :update, group, group_membership_request), group_membership_request: %{}

      assert html_response(conn, 404) =~ "Page not found"
      refute Repo.get_by(UserGroup, %{group_id: group.id, user_id: other_user.id})
    end

    test "fails if logged in user is not in group", %{conn: conn} do
      group = insert(:group)
      other_user = insert(:user)
      group_membership_request = insert(:group_membership_request, %{group: group, user: other_user, initiated_by_user: true})
      conn = put conn, group_invitation_path(conn, :update, group, group_membership_request), group_membership_request: %{}

      assert redirected_to(conn) == group_invitation_path(conn, :index, group)
      assert Repo.get(GroupMembershipRequest, group_membership_request.id)
      refute Repo.get_by(UserGroup, %{group_id: group.id, user_id: other_user.id})
    end

    test "fails if logged in user is in group but not owner of the group", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{users: [user]})
      other_user = insert(:user)
      group_membership_request = insert(:group_membership_request, %{group: group, user: other_user, initiated_by_user: true})
      conn = put conn, group_invitation_path(conn, :update, group, group_membership_request), group_membership_request: %{}

      assert redirected_to(conn) == group_invitation_path(conn, :index, group)
      assert Repo.get(GroupMembershipRequest, group_membership_request.id)
      refute Repo.get_by(UserGroup, %{group_id: group.id, user_id: other_user.id})
    end

    test "redirects and deletes group_membership_request if invited user is already in the group", %{conn: conn, logged_in_user: user} do
      other_user = insert(:user)
      group = insert(:group, %{owner: user, users: [user, other_user]})
      group_membership_request = insert(:group_membership_request, %{group: group, user: other_user, initiated_by_user: true})
      conn = put conn, group_invitation_path(conn, :update, group, group_membership_request), group_membership_request: %{}

      assert redirected_to(conn) == group_invitation_path(conn, :index, group)
      refute Repo.get(GroupMembershipRequest, group_membership_request.id)
    end

    test "fails if group_membership_request is created by group owner", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      other_user = insert(:user)
      group_membership_request = insert(:group_membership_request, %{group: group, user: other_user, initiated_by_user: false})
      conn = put conn, group_invitation_path(conn, :update, group, group_membership_request), group_membership_request: %{}

      assert redirected_to(conn) == group_invitation_path(conn, :index, group)
      assert Repo.get(GroupMembershipRequest, group_membership_request.id)
      refute Repo.get_by(UserGroup, %{group_id: group.id, user_id: other_user.id})
    end
  end

  describe "using :delete while authenticated" do
    setup do
      login_user()
    end

    test "deletes invite if user is the user on the invite", %{conn: conn, logged_in_user: user} do
      group = insert(:group)
      group_membership_request = insert(:group_membership_request, %{user: user, group: group, initiated_by_user: true})

      conn = delete conn, group_invitation_path(conn, :delete, group, group_membership_request)
      assert redirected_to(conn) == group_invitation_path(conn, :index, group)
      refute Repo.get(GroupMembershipRequest, group_membership_request.id)
    end

    test "deletes invite if user is the owner of the invite's group", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user})
      other_user = insert(:user)
      group_membership_request = insert(:group_membership_request, %{user: other_user, group: group, initiated_by_user: true})

      conn = delete conn, group_invitation_path(conn, :delete, group, group_membership_request)
      assert redirected_to(conn) == group_invitation_path(conn, :index, group)
      refute Repo.get(GroupMembershipRequest, group_membership_request.id)
    end

    test "fails if user is not on the invite or the owner of the group on the invite", %{conn: conn} do
      group = insert(:group)
      other_user = insert(:user)
      group_membership_request = insert(:group_membership_request, %{user: other_user, group: group, initiated_by_user: true})

      conn = delete conn, group_invitation_path(conn, :delete, group, group_membership_request)
      assert redirected_to(conn) == group_invitation_path(conn, :index, group)
      assert Repo.get(GroupMembershipRequest, group_membership_request.id)
    end
  end
end
