defmodule Pairmotron.PageControllerTest do
  use Pairmotron.ConnCase

  alias Pairmotron.UserPair
  import Pairmotron.TestHelper, only: [log_in: 2, create_pair: 1]

  test "redirects to login when no user is logged in", %{conn: conn} do
    conn = get conn, "/pairs"
    assert redirected_to(conn) == session_path(conn, :new)
  end

  describe "while authenticated" do
    setup do
      user = insert(:user)
      conn = build_conn
        |> log_in(user)
      {:ok, [conn: conn, logged_in_user: user]}
    end

    test "lists one active user", %{conn: conn, logged_in_user: user} do
      conn = get(conn, "/pairs")
      assert html_response(conn, 200) =~ user.name
    end

    test "does not list an inactive user", %{conn: conn} do
      user = insert(:user, active: false)
      conn = get(conn, "/pairs")
      refute html_response(conn, 200) =~ user.name
    end

    test "pairs two users together", %{conn: conn, logged_in_user: user1} do
      user2 = insert(:user)
      conn = get(conn, "/pairs")
      assert html_response(conn, 200) =~ user1.name
      assert html_response(conn, 200) =~ user2.name
    end

    test "displays link to retro :create for a pair that has no retrospective" do
    end

    test "does not re-pair after the first pair has been made", %{conn: conn, logged_in_user: user} do
      create_pair([user])
      new_user = insert(:user)
      conn = get(conn, "/pairs")
      assert html_response(conn, 200) =~ user.name
      refute html_response(conn, 200) =~ new_user.name
    end

    test "does not pairify for a week that is not current", %{conn: conn, logged_in_user: user} do
      conn = get conn, page_path(conn, :show, 1999, 1)
      refute html_response(conn, 200) =~ user.name
    end

    test "repairifying deletes current pairs and redirects to show", %{conn: conn, logged_in_user: user} do
      {year, week} = Timex.iso_week(Timex.today)
      create_pair([user])
      conn = delete conn, page_path(conn, :delete, year, week)
      assert redirected_to(conn) == page_path(conn, :show, year, week)
      refute Repo.get_by(UserPair, %{user_id: user.id})
    end

  end
end
