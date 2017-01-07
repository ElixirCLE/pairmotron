defmodule Pairmotron.PairRetroControllerTest do
  use Pairmotron.ConnCase

  alias Pairmotron.PairRetro
  import Pairmotron.TestHelper, only: [log_in: 2, create_pair: 1, create_pair: 3, create_retro: 2]

  @valid_attrs %{subject: "some content", reflection: "some content", pair_date: Timex.today}
  @invalid_attrs %{}

  test "redirects to sign-in when not logged in", %{conn: conn} do
    conn = get conn, user_path(conn, :index)
    assert redirected_to(conn) == session_path(conn, :new)
  end

  defp create_pair_and_retro(user) do
    pair = create_pair([user])
    retro = create_retro(user, pair)
    {pair, retro}
  end

  defp create_user_and_pair_and_retro() do
    user = insert(:user)
    pair = create_pair([user])
    retro = create_retro(user, pair)
    {user, pair, retro}
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
      {_pair, retro} = create_pair_and_retro(user)
      conn = get conn, pair_retro_path(conn, :index)
      assert html_response(conn, 200) =~ Ecto.Date.to_string(retro.pair_date)
    end

    test "does not list a retrospective of a different user", %{conn: conn} do
      {_other_user, _pair, retro} = create_user_and_pair_and_retro
      conn = get conn, pair_retro_path(conn, :index)
      refute html_response(conn, 200) =~ Ecto.Date.to_string(retro.pair_date)
    end

    test "renders form for new resources", %{conn: conn, logged_in_user: user} do
      pair = create_pair([user])
      conn = get conn, pair_retro_path(conn, :new, pair.id)
      assert html_response(conn, 200) =~ "New retrospective"
    end

    test "creates retro and redirects when data is valid and user is logged in", %{conn: conn, logged_in_user: user} do
      pair = create_pair([user])
      attrs = Map.merge(@valid_attrs, %{pair_id: Integer.to_string(pair.id),
                                        user_id: Integer.to_string(user.id)})
      conn = post conn, pair_retro_path(conn, :create), pair_retro: attrs
      assert redirected_to(conn) == pair_retro_path(conn, :index)
      assert Repo.get_by(PairRetro, attrs)
    end

    test "cannot create retro with a pair_date before the pair's week", %{conn: conn, logged_in_user: user} do
      pair = create_pair([user], 2016, 1)
      attrs = Map.merge(@valid_attrs, %{pair_date: ~D(1999-10-20),
                                        pair_id: Integer.to_string(pair.id),
                                        user_id: Integer.to_string(user.id)})
      conn = post conn, pair_retro_path(conn, :create), pair_retro: attrs
      assert html_response(conn, 200) =~ "New retrospective"
      assert html_response(conn, 200) =~ "cannot be before the week of the pair"
    end

    test "cannot create retro without a user_id parameter", %{conn: conn, logged_in_user: user} do
      pair = create_pair([user])
      attrs = Map.merge(@valid_attrs, %{pair_id: Integer.to_string(pair.id)})
      conn = post conn, pair_retro_path(conn, :create), pair_retro: attrs
      assert html_response(conn, 200) =~ "New retrospective"
      assert html_response(conn, 200) =~ "something went wrong"
      refute Repo.get_by(PairRetro, attrs)
    end

    test "cannot create retro when the retros user is not the logged in user", %{conn: conn} do
      user = insert(:user)
      pair = create_pair([user])
      attrs = Map.merge(@valid_attrs, %{pair_id: Integer.to_string(pair.id),
                                        user_id: Integer.to_string(user.id)})
      conn = post conn, pair_retro_path(conn, :create), pair_retro: attrs
      assert redirected_to(conn) == pair_retro_path(conn, :index)
      assert %{"error" => _} = conn.private.phoenix_flash
    end

    test "cannot create resource and renders errors when data is invalid", %{conn: conn} do
      conn = post conn, pair_retro_path(conn, :create), pair_retro: @invalid_attrs
      assert html_response(conn, 200) =~ "New retrospective"
    end

    test "can show the logged in user's retrospective", %{conn: conn, logged_in_user: user} do
      {_pair, retro} = create_pair_and_retro(user)
      conn = get conn, pair_retro_path(conn, :show, retro)
      assert html_response(conn, 200) =~ "Show retrospective"
    end

    test "cannot show other user's retrospective", %{conn: conn} do
      {_user, _pair, retro} = create_user_and_pair_and_retro()
      conn = get conn, pair_retro_path(conn, :show, retro)
      assert redirected_to(conn) == pair_retro_path(conn, :index)
      assert %{"error" => _} = conn.private.phoenix_flash
    end

    test "renders page not found when id is nonexistent", %{conn: conn} do
      conn = get conn, pair_retro_path(conn, :show, -1)
      assert html_response(conn, 404) =~ "Page not found"
    end

    test "renders form for editing logged in user's own resource", %{conn: conn, logged_in_user: user} do
      pair = create_pair([user])
      retro = create_retro(user, pair)
      conn = get conn, pair_retro_path(conn, :edit, retro)
      assert html_response(conn, 200) =~ "Edit retrospective"
    end

    test "does not render form for editing different user's resource", %{conn: conn} do
      {_user, _pair, retro} = create_user_and_pair_and_retro()
      conn = get conn, pair_retro_path(conn, :edit, retro)
      assert redirected_to(conn) == pair_retro_path(conn, :index)
      assert %{"error" => _} = conn.private.phoenix_flash
    end

    test "updates logged in users' retro and redirects when data is valid", %{conn: conn, logged_in_user: user} do
      pair = create_pair([user])
      attrs = Map.merge(@valid_attrs, %{pair_id: pair.id, user_id: user.id})
      pair_retro = Repo.insert! %PairRetro{user_id: user.id}
      conn = put conn, pair_retro_path(conn, :update, pair_retro), pair_retro: attrs
      assert redirected_to(conn) == pair_retro_path(conn, :show, pair_retro)
      assert Repo.get_by(PairRetro, attrs)
    end

    test "does not update retro with a pair_date before the pair's week", %{conn: conn, logged_in_user: user} do
      pair = create_pair([user], 2016, 1)
      attrs = Map.merge(@valid_attrs, %{pair_date: ~D(1999-10-20),
                                        pair_id: pair.id,
                                        user_id: user.id})
      pair_retro = Repo.insert! %PairRetro{user_id: user.id}
      conn = put conn, pair_retro_path(conn, :update, pair_retro), pair_retro: attrs
      assert html_response(conn, 200) =~ "Edit retrospective"
      assert html_response(conn, 200) =~ "cannot be before the week of the pair"
    end

    test "does not update retro of user who is not the logged in user", %{conn: conn} do
      user = insert(:user)
      pair = create_pair([user])
      attrs = Map.merge(@valid_attrs, %{pair_id: pair.id, user_id: user.id})
      pair_retro = Repo.insert! %PairRetro{}
      conn = put conn, pair_retro_path(conn, :update, pair_retro), pair_retro: attrs
      assert redirected_to(conn) == pair_retro_path(conn, :index)
      assert %{"error" => _} = conn.private.phoenix_flash
      refute Repo.get_by(PairRetro, attrs)
    end

    test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, logged_in_user: user} do
      pair_retro = Repo.insert! %PairRetro{user_id: user.id}
      conn = put conn, pair_retro_path(conn, :update, pair_retro), pair_retro: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit retrospective"
    end

    test "can delete the logged in users' retro", %{conn: conn, logged_in_user: user} do
      {_pair, retro} = create_pair_and_retro(user)
      conn = delete conn, pair_retro_path(conn, :delete, retro)
      assert redirected_to(conn) == pair_retro_path(conn, :index)
      refute Repo.get(PairRetro, retro.id)
    end

    test "can not delete retro of a user that is not logged in", %{conn: conn} do
      {_user, _pair, retro} = create_user_and_pair_and_retro()
      conn = delete conn, pair_retro_path(conn, :delete, retro)
      assert redirected_to(conn) == pair_retro_path(conn, :index)
      assert %{"error" => _} = conn.private.phoenix_flash
      assert Repo.get(PairRetro, retro.id)
    end
  end

  describe "as admin" do
    setup do
      user = insert(:user_admin)
      conn = build_conn
        |> log_in(user)
      {:ok, [conn: conn, logged_in_user: user]}
    end

    test "creates other user's retro and redirects", %{conn: conn} do
      user = insert(:user)
      pair = create_pair([user])
      attrs = Map.merge(@valid_attrs, %{pair_id: Integer.to_string(pair.id),
                                        user_id: Integer.to_string(user.id)})
      conn = post conn, pair_retro_path(conn, :create), pair_retro: attrs
      assert redirected_to(conn) == pair_retro_path(conn, :index)
      assert Repo.get_by(PairRetro, attrs)
    end

    test "renders form for editing other user's retrospective", %{conn: conn} do
      {_user, _pair, retro} = create_user_and_pair_and_retro()
      conn = get conn, pair_retro_path(conn, :edit, retro)
      assert html_response(conn, 200) =~ "Edit retrospective"
    end

    test "updates other user's retrospective and redirects when data is valid", %{conn: conn} do
      user = insert(:user)
      pair = create_pair([user])
      attrs = Map.merge(@valid_attrs, %{pair_id: pair.id, user_id: user.id})
      pair_retro = Repo.insert! %PairRetro{user_id: user.id}
      conn = put conn, pair_retro_path(conn, :update, pair_retro), pair_retro: attrs
      assert redirected_to(conn) == pair_retro_path(conn, :show, pair_retro)
      assert Repo.get_by(PairRetro, attrs)
    end

    test "can show other user's retrospective", %{conn: conn} do
      {_user, _pair, retro} = create_user_and_pair_and_retro()
      conn = get conn, pair_retro_path(conn, :show, retro)
      assert html_response(conn, 200) =~ "Show retrospective"
    end

    test "can delete other user's retrospective", %{conn: conn} do
      {_user, _pair, retro} = create_user_and_pair_and_retro()
      conn = delete conn, pair_retro_path(conn, :delete, retro)
      assert redirected_to(conn) == pair_retro_path(conn, :index)
      refute Repo.get(PairRetro, retro.id)
    end
  end
end
