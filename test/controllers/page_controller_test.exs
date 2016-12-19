defmodule Pairmotron.PageControllerTest do
  use Pairmotron.ConnCase

  alias Pairmotron.UserPair
  import Pairmotron.TestHelper, only: [log_in: 2, create_pair: 1]

  test "redirects to login when no user is logged in", %{conn: conn} do
    conn = get conn, "/pairs"
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "lists one active user", %{conn: conn} do
    user = insert(:user)
    conn = conn
      |> log_in(user)
      |> get("/pairs")
    assert html_response(conn, 200) =~ user.name
  end

  test "does not list an inactive user", %{conn: conn} do
    user = insert(:user, active: false)
    conn = conn
      |> log_in(user)
      |> get("/pairs")
    refute html_response(conn, 200) =~ user.name
  end

  test "pairs two users together", %{conn: conn} do
    [user1, user2] = insert_pair(:user)
    conn = conn
      |> log_in(user1)
      |> get("/pairs")
    assert html_response(conn, 200) =~ user1.name
    assert html_response(conn, 200) =~ user2.name
  end

  test "does not re-pair after the first pair has been made", %{conn: conn} do
    paired_users = [user1, user2] = insert_pair(:user)
    create_pair(paired_users)
    new_user = insert(:user)
    conn = conn
      |> log_in(new_user)
      |> get("/pairs")
    assert html_response(conn, 200) =~ user1.name
    assert html_response(conn, 200) =~ user2.name
    refute html_response(conn, 200) =~ new_user.name
  end

  test "does not pairify for a week that is not current", %{conn: conn} do
    [user1, user2] = insert_pair(:user)
    conn = log_in(conn, user1)
    conn = get conn, page_path(conn, :show, 1999, 1)
    refute html_response(conn, 200) =~ user1.name
    refute html_response(conn, 200) =~ user2.name
  end

  test "repairifying deletes current pairs and redirects to show", %{conn: conn} do
    {year, week} = Timex.iso_week(Timex.today)
    paired_users = [user1, user2] = insert_pair(:user)
    create_pair(paired_users)

    conn = log_in(conn, user1)
    conn = delete conn, page_path(conn, :delete, year, week)
    assert redirected_to(conn) == page_path(conn, :show, year, week)

    refute Repo.get_by(UserPair, %{user_id: user1.id})
    refute Repo.get_by(UserPair, %{user_id: user2.id})
  end
end
