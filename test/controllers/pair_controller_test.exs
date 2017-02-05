defmodule Pairmotron.PairControllerTest do
  use Pairmotron.ConnCase

  alias Pairmotron.{UserPair, User, Pair}
  import Pairmotron.TestHelper,
    only: [log_in: 2, create_pair: 1, create_pair: 3, create_retro: 2, create_pair_and_retro: 1]

  test "redirects to login when no user is logged in", %{conn: conn} do
    conn = get conn, "/pairs"
    assert redirected_to(conn) == session_path(conn, :new)
  end

  describe "while authenticated" do
    setup do
      user = insert(:user)
      conn = build_conn() |> log_in(user)
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

    test "displays link to retro :create for a pair and current user with no retrospective",
      %{conn: conn, logged_in_user: user} do
      pair = create_pair([user])
      conn = get(conn, "/pairs")
      assert html_response(conn, 200) =~ pair_retro_path(conn, :new, pair.id)
    end

    test "displays link to retro :create when the other user in pair has retro but current_user doesn't",
      %{conn: conn, logged_in_user: user} do
      other_user = insert(:user)
      pair = create_pair([user, other_user])
      create_retro(other_user, pair)
      conn = get(conn, "/pairs")
      assert html_response(conn, 200) =~ pair_retro_path(conn, :new, pair.id)
    end

    test "displays link to retro :show for pair and current user with retrospective",
      %{conn: conn, logged_in_user: user} do
      {_pair, retro} = create_pair_and_retro(user)
      conn = get(conn, "/pairs")
      assert html_response(conn, 200) =~ pair_retro_path(conn, :show, retro.id)
    end

    test "displays link to retro :show for pair and current user with retrospective for :show",
      %{conn: conn, logged_in_user: user} do
      {year, week} = Timex.iso_week(Timex.today)
      pair = create_pair([user], year, week)
      retro = create_retro(user, pair) # create_retro function defines pair_date as Timex.today
      conn = get conn, pair_path(conn, :show, year, week)
      assert html_response(conn, 200) =~ pair_retro_path(conn, :show, retro.id)
    end

    test "does not re-pair after the first pair has been made", %{conn: conn, logged_in_user: user} do
      create_pair([user])
      new_user = insert(:user)
      conn = get(conn, "/pairs")
      assert html_response(conn, 200) =~ user.name
      refute html_response(conn, 200) =~ new_user.name
    end

    test "does not pairify for a week that is not current", %{conn: conn, logged_in_user: user} do
      conn = get conn, pair_path(conn, :show, 1999, 1)
      refute html_response(conn, 200) =~ user.name
    end

    test "repairifying deletes invalid pairs and redirects to show", %{conn: conn, logged_in_user: user} do
      {year, week} = Timex.iso_week(Timex.today)
      user2 = insert(:user)
      create_pair([user, user2])
      Repo.update! User.changeset(user2, %{active: false})
      conn = delete conn, pair_path(conn, :delete, year, week)
      assert redirected_to(conn) == pair_path(conn, :show, year, week)
      refute Repo.get_by(UserPair, %{user_id: user2.id})
    end

    test "repairifying does not affect retro'd pairs", %{conn: conn, logged_in_user: user} do
      {year, week} = Timex.iso_week(Timex.today)
      user2 = insert(:user)
      pair = create_pair([user, user2])
      create_retro(user, pair)
      user3 = insert(:user)
      delete conn, pair_path(conn, :delete, year, week)
      refute Repo.get_by(UserPair, %{user_id: user3.id, pair_id: pair.id})
    end

    test "repairifying does not delete valid pairs", %{conn: conn, logged_in_user: user} do
      {year, week} = Timex.iso_week(Timex.today)
      user2 = insert(:user)
      pair = create_pair([user, user2])
      delete conn, pair_path(conn, :delete, year, week)
      assert Repo.get(Pair, pair.id)
    end
  end
end
