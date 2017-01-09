defmodule Pairmotron.UserControllerTest do
  use Pairmotron.ConnCase

  alias Pairmotron.User
  import Pairmotron.TestHelper, only: [log_in: 2]

  @valid_attrs %{email: "email", name: "name", password: "password", password_confirmation: "password"}
  @invalid_attrs %{}

  test "redirects to sign-in when not logged in", %{conn: conn} do
    conn = get conn, user_path(conn, :index)
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
      conn = get conn, user_path(conn, :index)
      assert html_response(conn, 200) =~ "Users"
    end

    test "renders form for new resources", %{conn: conn} do
      conn = get conn, user_path(conn, :new)
      assert html_response(conn, 200) =~ "New User"
    end

    test "creates resource and redirects when data is valid", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @valid_attrs
      assert redirected_to(conn) == user_path(conn, :index)
      assert Repo.get_by(User, %{email: "email", name: "name"})
    end

    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @invalid_attrs
      assert html_response(conn, 200) =~ "New User"
    end

    test "shows chosen resource", %{conn: conn} do
      user = insert(:user)
      conn = get conn, user_path(conn, :show, user)
      assert html_response(conn, 200) =~ "Show user"
    end

    test "renders page not found when id is nonexistent", %{conn: conn} do
      assert_error_sent 404, fn ->
        get conn, user_path(conn, :show, -1)
      end
    end

    test "renders form for editing own resource", %{conn: conn, logged_in_user: user} do
      conn = get conn, user_path(conn, :edit, user)
      assert html_response(conn, 200) =~ "Edit user"
    end

    test "redirects when editing other users resource", %{conn: conn} do
      user = insert(:user)
      conn = get conn, user_path(conn, :edit, user)
      assert redirected_to(conn) == user_path(conn, :index)
    end

    test "updates user and redirects if user is logged in user", %{conn: conn, logged_in_user: user} do
      conn = put conn, user_path(conn, :update, user), user: @valid_attrs
      assert redirected_to(conn) == user_path(conn, :show, user)
      expected_attrs = Map.drop(@valid_attrs, [:password, :password_confirmation])
      assert Repo.get_by(User, expected_attrs)
    end

    test "does not update user if user is not logged in user", %{conn: conn} do
      user = insert(:user)
      conn = put conn, user_path(conn, :update, user), user: @valid_attrs
      assert redirected_to(conn) == user_path(conn, :index)
      expected_attrs = Map.drop(@valid_attrs, [:password, :password_confirmation])
      refute Repo.get_by(User, expected_attrs)
    end

    test "does not update chosen resource and renders errors when data is invalid", 
      %{conn: conn, logged_in_user: user} do
      conn = log_in(conn, user)
      conn = put conn, user_path(conn, :update, user), user: %{name: ""}
      assert html_response(conn, 200) =~ "Edit user"
    end

    test "deletes the logged in user", %{conn: conn, logged_in_user: user} do
      conn = delete conn, user_path(conn, :delete, user)
      assert redirected_to(conn) == user_path(conn, :index)
      refute Repo.get(User, user.id)
    end

    test "does not delete a non-logged in user", %{conn: conn} do
      user = insert(:user)
      conn = delete conn, user_path(conn, :delete, user)
      assert redirected_to(conn) == user_path(conn, :index)
      assert Repo.get(User, user.id)
    end
  end

  describe "as admin" do
    setup do
      user = insert(:user_admin)
      conn = build_conn
        |> log_in(user)
      {:ok, [conn: conn, logged_in_user: user]}
    end

    test "renders form for editing other user", %{conn: conn} do
      user = insert(:user)
      conn = get conn, user_path(conn, :edit, user)
      assert html_response(conn, 200) =~ "Edit user"
    end

    test "updates other user and redirects", %{conn: conn} do
      user = insert(:user)
      conn = put conn, user_path(conn, :update, user), user: @valid_attrs
      assert redirected_to(conn) == user_path(conn, :show, user)
      expected_attrs = Map.drop(@valid_attrs, [:password, :password_confirmation])
      assert Repo.get_by(User, expected_attrs)
    end

    test "deletes other user", %{conn: conn} do
      user = insert(:user)
      conn = delete conn, user_path(conn, :delete, user)
      assert redirected_to(conn) == user_path(conn, :index)
      refute Repo.get(User, user.id)
    end
  end
end
