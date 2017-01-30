defmodule Pairmotron.ProfileControllerTest do
  use Pairmotron.ConnCase

  alias Pairmotron.User
  import Pairmotron.TestHelper, only: [log_in: 2]

  @valid_attrs %{email: "email", name: "name", password: "password", password_confirmation: "password"}

  test "redirects to sign-in when not logged in", %{conn: conn} do
    conn = get conn, profile_path(conn, :show)
    assert redirected_to(conn) == session_path(conn, :new)
  end

  describe "while authenticated" do
    setup do
      user = insert(:user)
      conn = build_conn() |> log_in(user)
      {:ok, [conn: conn, logged_in_user: user]}
    end

    test "shows the current user", %{conn: conn, logged_in_user: user} do
      conn = get conn, profile_path(conn, :show)
      assert html_response(conn, 200) =~ "User Profile"
      assert html_response(conn, 200) =~ user.name
      assert html_response(conn, 200) =~ user.email
    end

    test "lists the current user's groups", %{conn: conn, logged_in_user: user} do
      group1 = insert(:group, %{owner: user, users: [user]})
      group2 = insert(:group, %{owner: user, users: [user]})
      conn = get conn, profile_path(conn, :show)
      assert html_response(conn, 200) =~ group1.name
      assert html_response(conn, 200) =~ group_path(conn, :show, group1)
      assert html_response(conn, 200) =~ group2.name
      assert html_response(conn, 200) =~ group_path(conn, :show, group2)
    end

    test "links to group edit if current user is owner", %{conn: conn, logged_in_user: user} do
      group1 = insert(:group, %{owner: user, users: [user]})
      conn = get conn, profile_path(conn, :show)
      assert html_response(conn, 200) =~ "Manage"
      assert html_response(conn, 200) =~ group_path(conn, :edit, group1)
    end

    test "doesn't link to group edit if current user is not owner", %{conn: conn, logged_in_user: user} do
      group1 = insert(:group, %{users: [user]})
      conn = get conn, profile_path(conn, :show)
      refute html_response(conn, 200) =~ group_path(conn, :edit, group1)
    end

    test "renders form for editing the current user", %{conn: conn} do
      conn = get conn, profile_path(conn, :edit)
      assert html_response(conn, 200) =~ "Edit Profile"
    end

    test "updates current user", %{conn: conn, logged_in_user: user} do
      conn = put conn, profile_path(conn, :update, user), user: @valid_attrs
      assert redirected_to(conn) == profile_path(conn, :show)
      expected_attrs = Map.drop(@valid_attrs, [:password, :password_confirmation])
      assert Repo.get_by(User, expected_attrs)
    end

    test "cannot update is_admin of current_user", %{conn: conn, logged_in_user: user} do
      refute user.is_admin
      put conn, profile_path(conn, :update, user), user: %{is_admin: true}
      updated_user = Repo.get(User, user.id)
      refute updated_user.is_admin
    end

    test "does not update user with invalid input", %{conn: conn, logged_in_user: user} do
      conn = put conn, profile_path(conn, :update, user), user: %{name: ""}
      assert html_response(conn, 200) =~ "Edit Profile"
    end
  end
end
