defmodule Pairmotron.UserControllerTest do
  use Pairmotron.ConnCase

  alias Pairmotron.User
  @valid_attrs %{email: "some content", name: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, user_path(conn, :index)
    assert html_response(conn, 200) =~ "Users"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, user_path(conn, :new)
    assert html_response(conn, 200) =~ "New user"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @valid_attrs
    assert redirected_to(conn) == user_path(conn, :index)
    assert Repo.get_by(User, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert html_response(conn, 200) =~ "New user"
  end

  test "shows chosen resource", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = get conn, user_path(conn, :show, user)
    assert html_response(conn, 200) =~ "Show user"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, user_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = get conn, user_path(conn, :edit, user)
    assert html_response(conn, 200) =~ "Edit user"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = put conn, user_path(conn, :update, user), user: @valid_attrs
    assert redirected_to(conn) == user_path(conn, :show, user)
    assert Repo.get_by(User, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = put conn, user_path(conn, :update, user), user: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit user"
  end

  test "deletes chosen resource", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = delete conn, user_path(conn, :delete, user)
    assert redirected_to(conn) == user_path(conn, :index)
    refute Repo.get(User, user.id)
  end

  test "activates chosen resource", %{conn: conn} do
    user = Repo.insert! %User{name: "foo", email: "bar", active: false}
    conn = get conn, user_path(conn, :index)
    assert html_response(conn, 200) =~ "Inactive"

    conn = put conn, user_activate_path(conn, :activate, user)
    assert redirected_to(conn) == user_path(conn, :index)

    conn = get conn, user_path(conn, :index)
    assert html_response(conn, 200) =~ "Active"
  end

  test "inactivates chosen resource", %{conn: conn} do
    user = Repo.insert! %User{name: "foo", email: "bar", active: true}
    conn = get conn, user_path(conn, :index)
    assert html_response(conn, 200) =~ "Active"

    conn = put conn, user_deactivate_path(conn, :deactivate, user)
    assert redirected_to(conn) == user_path(conn, :index)

    conn = get conn, user_path(conn, :index)
    assert html_response(conn, 200) =~ "Inactive"
  end
end
