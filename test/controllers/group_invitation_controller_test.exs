defmodule Pairmotron.GroupInvitationControllerTest do
  use Pairmotron.ConnCase

  alias Pairmotron.{GroupMembershipRequest, UserGroup}

  import Pairmotron.TestHelper, only: [log_in: 2]

  test "redirects to sign-in when not logged in", %{conn: conn} do
    group = insert(:group)
    conn = get conn, group_invitation_path(conn, :index, group.id)
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
      conn = get conn, group_invitation_path(conn, :index, group.id)
      assert html_response(conn, 200) =~ "There are no active invitations for this group at this time"
    end

    test "lists an invitation that is associated with the group", %{conn: conn, group: group} do
      user = insert(:user)
      insert(:group_membership_request, %{user: user, group: group, initiated_by_user: false})
      conn = get conn, group_invitation_path(conn, :index, group.id)
      assert html_response(conn, 200) =~ user.name
      assert html_response(conn, 200) =~ "Awaiting Response"
    end

    test "lists an invitation initiated by user and links to accept the invitation", %{conn: conn, group: group} do
      user = insert(:user)
      group_membership_request = insert(:group_membership_request, %{user: user, group: group, initiated_by_user: true})
      conn = get conn, group_invitation_path(conn, :index, group.id)
      assert html_response(conn, 200) =~ user.name
      assert html_response(conn, 200) =~ "Accept Membership Request"
      assert html_response(conn, 200) =~ group_invitation_path(conn, :update, group_membership_request, group.id)
    end

    test "does not list invitations not associated with the group", %{conn: conn, group: group} do
      user = insert(:user)
      other_group = insert(:group)
      insert(:group_membership_request, %{user: user, group: other_group, initiated_by_user: false})
      conn = get conn, group_invitation_path(conn, :index, group.id)
      assert html_response(conn, 200) =~ "There are no active invitations for this group at this time"
    end

    test "does not list invitations if user is not owner of group", %{conn: conn} do
      group = insert(:group)
      conn = get conn, group_invitation_path(conn, :index, group.id)
      assert redirected_to(conn) == group_path(conn, :show, group)
    end

    test "handles nonexistent group", %{conn: conn} do
      conn = get conn, group_invitation_path(conn, :index, 1)
      assert html_response(conn, 404) =~ "not found"
    end
  end
end
