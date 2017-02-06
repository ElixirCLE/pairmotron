defmodule Pairmotron.UsersGroupMembershipRequestControllerTest do
  use Pairmotron.ConnCase

  import Pairmotron.TestHelper, only: [log_in: 2]

  test "redirects to sign-in when not logged in", %{conn: conn} do
    conn = get conn, users_group_membership_request_path(conn, :index)
    assert redirected_to(conn) == session_path(conn, :new)
  end

  describe "while authenticated" do
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
      insert(:group_membership_request, %{initiated_by_user: false, user: user, group: group})
      conn = get conn, users_group_membership_request_path(conn, :index)
      assert html_response(conn, 200) =~ "Invited by Group"
      assert html_response(conn, 200) =~ "Accept Invitation"
      refute html_response(conn, 200) =~ "You have no active invitations at this time"
    end
  end
end
