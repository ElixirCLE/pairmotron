defmodule Pairmotron.GroupControllerTest do
  use Pairmotron.ConnCase

  alias Pairmotron.Group
  import Pairmotron.TestHelper, only: [log_in: 2]

  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  test "redirects to sign-in when not logged in", %{conn: conn} do
    conn = get conn, group_path(conn, :index)
    assert redirected_to(conn) == session_path(conn, :new)
  end

  describe "while authenticated" do
    setup do
      user = insert(:user)
      conn = build_conn
        |> log_in(user)
      {:ok, [conn: conn, logged_in_user: user]}
    end

    test "lists all entries on index", %{conn: conn} do
      conn = get conn, group_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing groups"
    end

    test "renders form for new resources", %{conn: conn} do
      conn = get conn, group_path(conn, :new)
      assert html_response(conn, 200) =~ "New group"
    end

    test "creates resource and redirects when data is valid", %{conn: conn, logged_in_user: user} do
      attrs = Map.merge(@valid_attrs, %{owner_id: Integer.to_string(user.id)})
      conn = post conn, group_path(conn, :create), group: attrs
      assert redirected_to(conn) == group_path(conn, :index)
      assert Repo.get_by(Group, attrs)
    end

    test "created group's owner is in the group's users", %{conn: conn, logged_in_user: user} do
      attrs = Map.merge(@valid_attrs, %{owner_id: Integer.to_string(user.id)})
      post conn, group_path(conn, :create), group: attrs
      group = Repo.get_by(Group, attrs) |> Repo.preload(:users)
      assert [only_user] = group.users
      assert only_user.id == user.id
    end

    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      conn = post conn, group_path(conn, :create), group: @invalid_attrs
      assert html_response(conn, 200) =~ "New group"
    end

    test "shows chosen resource", %{conn: conn} do
      group = insert(:group)
      conn = get conn, group_path(conn, :show, group)
      assert html_response(conn, 200) =~ "Show group"
    end

    test "renders page not found when id is nonexistent", %{conn: conn} do
      assert_error_sent 404, fn ->
        get conn, group_path(conn, :show, -1)
      end
    end

    test "renders form for editing chosen resource", %{conn: conn, logged_in_user: user} do
      group = insert(:group, owner: user)
      conn = get conn, group_path(conn, :edit, group)
      assert html_response(conn, 200) =~ "Edit group"
    end

    test "does not allow editing a group not owned by logged in user", %{conn: conn} do
      group = insert(:group)
      conn = get conn, group_path(conn, :edit, group)
      assert redirected_to(conn) == group_path(conn, :index)
    end

    test "updates chosen resource and redirects when data is valid", %{conn: conn, logged_in_user: user} do
      group = insert(:group, owner: user)
      conn = put conn, group_path(conn, :update, group), group: @valid_attrs
      assert redirected_to(conn) == group_path(conn, :show, group)
      assert Repo.get_by(Group, @valid_attrs)
    end

    test "does not allow updating a group not owned by logged in user", %{conn: conn} do
      group = insert(:group)
      conn = put conn, group_path(conn, :update, group), group: @valid_attrs
      assert redirected_to(conn) == group_path(conn, :index)
      refute Repo.get_by(Group, @valid_attrs)
    end

    test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, logged_in_user: user} do
      group = Repo.insert! %Group{owner: user}
      conn = put conn, group_path(conn, :update, group), group: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit group"
    end

    test "deletes chosen resource", %{conn: conn, logged_in_user: user} do
      group = insert(:group, owner: user)
      conn = delete conn, group_path(conn, :delete, group)
      assert redirected_to(conn) == group_path(conn, :index)
      refute Repo.get(Group, group.id)
    end

    test "does not delete a group not owned by logged in user", %{conn: conn} do
      group = Repo.insert! %Group{}
      conn = delete conn, group_path(conn, :delete, group)
      assert redirected_to(conn) == group_path(conn, :index)
      assert Repo.get(Group, group.id)
    end

  end
  describe "as admin" do
    setup do
      user = insert(:user_admin)
      conn = build_conn
        |> log_in(user)
      {:ok, [conn: conn, logged_in_user: user]}
    end

    test "admin may edit a group not owned by admin", %{conn: conn, logged_in_user: user} do
      group = insert(:group, owner: user)
      conn = get conn, group_path(conn, :edit, group)
      assert html_response(conn, 200) =~ "Edit group"
    end

    test "admin may update a group not owned by admin", %{conn: conn} do
      group = insert(:group)
      conn = put conn, group_path(conn, :update, group), group: @valid_attrs
      assert redirected_to(conn) == group_path(conn, :show, group)
      assert Repo.get_by(Group, @valid_attrs)
    end

    test "admin may delete a group not owned by admin", %{conn: conn} do
      group = Repo.insert! %Group{}
      conn = delete conn, group_path(conn, :delete, group)
      assert redirected_to(conn) == group_path(conn, :index)
      refute Repo.get(Group, group.id)
    end
  end
end
