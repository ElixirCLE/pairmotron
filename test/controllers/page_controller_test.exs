defmodule Pairmotron.PageControllerTest do
  use Pairmotron.ConnCase
  alias Pairmotron.{Pair, UserPair}

  def log_in(conn, user) do
    conn |> Plug.Conn.assign(:current_user, user)
  end

  def create_pair(users) do
    {year, week} = Timex.iso_week(Timex.today)
    create_pair(users, year, week)
  end

  def create_pair(users, year, week) do
    pair_changeset = Pair.changeset(%Pair{}, %{year: year, week: week})
    pair = Pairmotron.Repo.insert!(pair_changeset)
    users
    |> Enum.map(&(UserPair.changeset(%UserPair{}, %{pair_id: pair.id, user_id: &1.id})))
    |> List.flatten
    |> Enum.map(&(Repo.insert! &1))
  end

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
