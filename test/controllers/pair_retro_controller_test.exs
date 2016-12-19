defmodule Pairmotron.PairRetroControllerTest do
  use Pairmotron.ConnCase

  alias Pairmotron.PairRetro
  import Pairmotron.TestHelper, only: [log_in: 2, create_pair: 1, create_retro: 2]

  @valid_attrs %{comment: "some content"}
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
      conn = get conn, pair_retro_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing your retrospectives"
    end

    test "lists the current user's retrospectives", %{conn: conn, logged_in_user: user} do
      pair = create_pair([user])
      retro = create_retro(user, pair)
      conn = get conn, pair_retro_path(conn, :index)
      assert html_response(conn, 200) =~ retro.comment
    end

    test "does not list a retrospective of a different user", %{conn: conn} do
      other_user = insert(:user)
      pair = create_pair([other_user])
      retro = create_retro(other_user, pair)
      conn = get conn, pair_retro_path(conn, :index)
      refute html_response(conn, 200) =~ retro.comment
    end

    test "renders form for new resources", %{conn: conn, logged_in_user: user1} do
      user2 = insert(:user)
      pair = create_pair([user1, user2])
      conn = get conn, pair_retro_path(conn, :new, pair.id)
      assert html_response(conn, 200) =~ "New retrospective"
    end

    test "creates resource and redirects when data is valid", %{conn: conn} do
      conn = post conn, pair_retro_path(conn, :create), pair_retro: @valid_attrs
      assert redirected_to(conn) == pair_retro_path(conn, :index)
      assert Repo.get_by(PairRetro, @valid_attrs)
    end

    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      conn = post conn, pair_retro_path(conn, :create), pair_retro: @invalid_attrs
      assert html_response(conn, 200) =~ "New retrospective"
    end

    test "shows chosen resource", %{conn: conn} do
      pair_retro = Repo.insert! %PairRetro{}
      conn = get conn, pair_retro_path(conn, :show, pair_retro)
      assert html_response(conn, 200) =~ "Show retrospective"
    end

    test "renders page not found when id is nonexistent", %{conn: conn} do
      assert_error_sent 404, fn ->
        get conn, pair_retro_path(conn, :show, -1)
      end
    end

    test "renders form for editing chosen resource", %{conn: conn} do
      pair_retro = Repo.insert! %PairRetro{}
      conn = get conn, pair_retro_path(conn, :edit, pair_retro)
      assert html_response(conn, 200) =~ "Edit retrospective"
    end

    test "updates chosen resource and redirects when data is valid", %{conn: conn} do
      pair_retro = Repo.insert! %PairRetro{}
      conn = put conn, pair_retro_path(conn, :update, pair_retro), pair_retro: @valid_attrs
      assert redirected_to(conn) == pair_retro_path(conn, :show, pair_retro)
      assert Repo.get_by(PairRetro, @valid_attrs)
    end

    test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
      pair_retro = Repo.insert! %PairRetro{}
      conn = put conn, pair_retro_path(conn, :update, pair_retro), pair_retro: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit retrospective"
    end
  end
end
