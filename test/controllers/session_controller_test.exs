defmodule Pairmotron.SessionControllerTest do
  use Pairmotron.ConnCase

  alias Pairmotron.User
  import Pairmotron.TestHelper, only: [guardian_log_in: 2]

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, session_path(conn, :new)
    assert html_response(conn, 200) =~ "Login"
  end

  test "redirects to /pairs when user is logged in", %{conn: conn} do
    conn = conn |> guardian_log_in(insert(:user))
    conn = get conn, session_path(conn, :new)
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "logging in with proper credentials redirects to /pairs", %{conn: conn} do
    %User{email: user_email, password: user_pw} = insert(:user_with_password)
    params = %{"user" => %{email: user_email, password: user_pw}}
    conn = post conn, session_path(conn, :create), params
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "logging in with no email fails with error message", %{conn: conn} do
    %User{password: user_pw} = insert(:user)
    params = %{"user" => %{password: user_pw}}
    conn = post conn, session_path(conn, :create), params
    assert html_response(conn, 200) =~ "Login"
    assert html_response(conn, 200) =~ "Name and/or password are incorrect"
  end

  test "logging in with an incorrect password fails with error message", %{conn: conn} do
    %User{email: user_email, password: _user_pw} = insert(:user_with_password)
    params = %{"user" => %{email: user_email, password: "bad_password"}}
    conn = post conn, session_path(conn, :create), params
    assert html_response(conn, 200) =~ "Login"
    assert html_response(conn, 200) =~ "Name and/or password are incorrect"
  end

  test "logging in with an email that doesn't exist fails with error message", %{conn: conn} do
    params = %{"user" => %{email: "unknown email", password: "password"}}
    conn = post conn, session_path(conn, :create), params
    assert html_response(conn, 200) =~ "Login"
    assert html_response(conn, 200) =~ "Name and/or password are incorrect"
  end

  test "logging in with no password fails with an error message", %{conn: conn} do
    %User{email: user_email, password: _user_pw} = insert(:user)
    params = %{"user" => %{email: user_email}}
    conn = post conn, session_path(conn, :create), params
    assert html_response(conn, 200) =~ "Login"
    assert html_response(conn, 200) =~ "Name and/or password are incorrect"
  end

  test "logging in with a nil password fails with an error message", %{conn: conn} do
    %User{email: user_email, password: _user_pw} = insert(:user)
    params = %{"user" => %{email: user_email, password: nil}}
    conn = post conn, session_path(conn, :create), params
    assert html_response(conn, 200) =~ "Login"
    assert html_response(conn, 200) =~ "Name and/or password are incorrect"
  end
end
