defmodule Pairmotron.PairRetroControllerTest do
  use Pairmotron.ConnCase

  alias Pairmotron.PairRetro
  import Pairmotron.TestHelper,
    only: [create_retro: 2, create_pair_and_retro: 2]

  @valid_attrs %{subject: "some content", reflection: "some content", pair_date: Timex.today}
  @invalid_attrs %{}

  test "redirects to sign-in when not logged in", %{conn: conn} do
    conn = get conn, pair_retro_path(conn, :index)
    assert redirected_to(conn) == session_path(conn, :new)
  end

  defp create_user_and_pair_and_retro() do
    user = insert(:user)
    group = insert(:group, %{owner: user, users: [user]})
    pair = insert(:pair, %{group: group, users: [user]})
    retro = insert(:retro, user: user, pair: pair)
    {user, pair, retro}
  end

  describe "using :index while authenticated" do
    setup do
      login_user()
    end

    test "lists all entries", %{conn: conn} do
      conn = get conn, pair_retro_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing your retrospectives"
    end

    test "lists the current user's retrospectives", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      {_pair, retro} = create_pair_and_retro(user, group)
      conn = get conn, pair_retro_path(conn, :index)
      assert html_response(conn, 200) =~ Ecto.Date.to_string(retro.pair_date)
    end

    test "does not list a retrospective of a different user", %{conn: conn} do
      {_other_user, _pair, retro} = create_user_and_pair_and_retro()
      conn = get conn, pair_retro_path(conn, :index)
      refute html_response(conn, 200) =~ Ecto.Date.to_string(retro.pair_date)
    end
  end

  describe "using :new while authenticated" do
    setup do
      login_user()
    end

    test "renders form if user is in the pair", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      pair = insert(:pair, %{group: group, users: [user]})
      conn = get conn, pair_retro_path(conn, :new, pair.id)
      assert html_response(conn, 200) =~ "New retrospective"
    end
  end

  describe "using :create while authenticated" do
    setup do
      login_user()
    end

    test "creates retro and redirects when data is valid", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      pair = insert(:pair, %{group: group, users: [user]})

      attrs = Map.merge(@valid_attrs, %{pair_id: Integer.to_string(pair.id),
                                        user_id: Integer.to_string(user.id)})

      conn = post conn, pair_retro_path(conn, :create), pair_retro: attrs
      assert redirected_to(conn) == pair_retro_path(conn, :index)
      assert Repo.get_by(PairRetro, attrs)
    end

    test "fails with a pair_date before the pair's week", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      pair = insert(:pair, %{group: group, users: [user], year: 2016, week: 1})

      attrs = Map.merge(@valid_attrs, %{pair_date: ~D(1999-10-20),
                                        pair_id: Integer.to_string(pair.id),
                                        user_id: Integer.to_string(user.id)})

      conn = post conn, pair_retro_path(conn, :create), pair_retro: attrs
      assert html_response(conn, 200) =~ "New retrospective"
      assert html_response(conn, 200) =~ "cannot be before the week of the pair"
    end

    test "fails without a pair_date parameter", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      pair = insert(:pair, %{group: group, users: [user]})

      attrs = %{pair_id: Integer.to_string(pair.id), user_id: Integer.to_string(user.id)}

      conn = post conn, pair_retro_path(conn, :create), pair_retro: attrs
      assert html_response(conn, 200) =~ "New retrospective"
      assert html_response(conn, 200) =~ "something went wrong"
      refute Repo.get_by(PairRetro, attrs)
    end

    test "creates retro without user_id parameter", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      pair = insert(:pair, %{group: group, users: [user]})

      attrs = Map.merge(@valid_attrs, %{pair_id: Integer.to_string(pair.id)})

      conn = post conn, pair_retro_path(conn, :create), pair_retro: attrs
      assert redirected_to(conn) == pair_retro_path(conn, :index)
      assert Repo.get_by(PairRetro, %{user_id: user.id})
    end

    test "ignores user_id parameter and uses logged in user", %{conn: conn, logged_in_user: user} do
      other_user = insert(:user)
      group = insert(:group, %{owner: user, users: [user]})
      pair = insert(:pair, %{group: group, users: [user]})

      attrs = Map.merge(@valid_attrs, %{pair_id: Integer.to_string(pair.id),
                                        user_id: Integer.to_string(other_user.id)})

      conn = post conn, pair_retro_path(conn, :create), pair_retro: attrs
      assert redirected_to(conn) == pair_retro_path(conn, :index)
      refute Repo.get_by(PairRetro, %{user_id: other_user.id})
      assert Repo.get_by(PairRetro, %{user_id: user.id})
    end

    test "fails if logged in user is not in pair", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      pair = insert(:pair, %{group: group, users: []})

      attrs = Map.merge(@valid_attrs, %{pair_id: Integer.to_string(pair.id),
                                        user_id: Integer.to_string(user.id)})

      conn = post conn, pair_retro_path(conn, :create), pair_retro: attrs
      assert redirected_to(conn) == pair_retro_path(conn, :index)
      assert %{"error" => _} = conn.private.phoenix_flash
    end
  end

  describe "using :show while authenticated" do
    setup do
      login_user()
    end

    test "displays a logged in user's retrospective", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      {_pair, retro} = create_pair_and_retro(user, group)
      conn = get conn, pair_retro_path(conn, :show, retro)
      assert html_response(conn, 200) =~ "Show retrospective"
    end

    test "does not display a different user's retrospective", %{conn: conn} do
      {_user, _pair, retro} = create_user_and_pair_and_retro()
      conn = get conn, pair_retro_path(conn, :show, retro)
      assert redirected_to(conn) == pair_retro_path(conn, :index)
      assert %{"error" => _} = conn.private.phoenix_flash
    end

    test "renders page not found when id is nonexistent", %{conn: conn} do
      conn = get conn, pair_retro_path(conn, :show, -1)
      assert html_response(conn, 404) =~ "Page not found"
    end
  end

  describe "using :edit while authenticated" do
    setup do
      login_user()
    end

    test "renders form for editing logged in user's own resource", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      pair = insert(:pair, %{group: group, users: [user]})
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
  end

  describe "using :update while authenticated" do
    setup do
      login_user()
    end

    test "updates logged in users' retro and redirects when data is valid", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      pair = insert(:pair, %{group: group, users: [user]})
      pair_retro = insert(:retro, %{user: user, pair: pair})

      attrs = Map.merge(@valid_attrs, %{subject: "different subject", reflection: "learned so much more"})

      conn = put conn, pair_retro_path(conn, :update, pair_retro), pair_retro: attrs
      assert redirected_to(conn) == pair_retro_path(conn, :show, pair_retro)
      assert Repo.get_by(PairRetro, attrs)
    end

    test "fails with a pair_date before the pair's week", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      pair = insert(:pair, %{group: group, users: [user], year: 2016, week: 1})
      pair_retro = insert(:retro, %{user: user, pair: pair})

      new_pair_date = {1999, 10, 20} |> Ecto.Date.from_erl
      attrs = Map.merge(@valid_attrs, %{pair_date: new_pair_date})

      conn = put conn, pair_retro_path(conn, :update, pair_retro), pair_retro: attrs
      assert html_response(conn, 200) =~ "Edit retrospective"
      assert html_response(conn, 200) =~ "cannot be before the week of the pair"
    end

    test "fails to update a different user's retro", %{conn: conn, logged_in_user: user} do
      other_user = insert(:user)
      group = insert(:group, %{owner: user, users: [user]})
      pair = insert(:pair, %{group: group, users: [other_user]})
      pair_retro = insert(:retro, %{pair: pair, user: other_user})

      attrs = Map.merge(@valid_attrs, %{pair_id: pair.id, user_id: user.id})

      conn = put conn, pair_retro_path(conn, :update, pair_retro), pair_retro: attrs
      assert redirected_to(conn) == pair_retro_path(conn, :index)
      assert %{"error" => _} = conn.private.phoenix_flash
      refute Repo.get_by(PairRetro, attrs)
    end

    test "fails to change retro to a different user", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      pair = insert(:pair, %{group: group, users: [user]})
      other_user = insert(:user)
      pair_retro = insert(:retro, %{pair: pair, user: user})

      attrs = Map.merge(@valid_attrs, %{pair_id: pair.id, user_id: other_user.id})

      put conn, pair_retro_path(conn, :update, pair_retro), pair_retro: attrs
      refute Repo.get_by(PairRetro, attrs)
    end

    test "fails to change retro to a different pair", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      pair = insert(:pair, %{group: group, users: [user]})
      other_pair = insert(:pair, %{group: group})
      pair_retro = insert(:retro, %{pair: pair, user: user})

      attrs = Map.merge(@valid_attrs, %{pair_id: other_pair.id, user_id: user.id})

      put conn, pair_retro_path(conn, :update, pair_retro), pair_retro: attrs
      refute Repo.get_by(PairRetro, attrs)
    end

    test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      pair = insert(:pair, %{group: group, users: [user]})
      pair_retro = Repo.insert! %PairRetro{user_id: user.id, pair_id: pair.id}

      conn = put conn, pair_retro_path(conn, :update, pair_retro), pair_retro: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit retrospective"
    end
  end

  describe "using :delete while authenticated" do
    setup do
      login_user()
    end

    test "deletes the logged in users' retro", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      {_pair, retro} = create_pair_and_retro(user, group)

      conn = delete conn, pair_retro_path(conn, :delete, retro)
      assert redirected_to(conn) == pair_retro_path(conn, :index)
      refute Repo.get(PairRetro, retro.id)
    end

    test "fails to delete retro of a user that is not logged in", %{conn: conn} do
      {_user, _pair, retro} = create_user_and_pair_and_retro()

      conn = delete conn, pair_retro_path(conn, :delete, retro)
      assert redirected_to(conn) == pair_retro_path(conn, :index)
      assert %{"error" => _} = conn.private.phoenix_flash
      assert Repo.get(PairRetro, retro.id)
    end
  end

  describe "as admin" do
    setup do
      login_admin_user()
    end

    test "renders form for editing other user's retrospective", %{conn: conn} do
      {_user, _pair, retro} = create_user_and_pair_and_retro()
      conn = get conn, pair_retro_path(conn, :edit, retro)
      assert html_response(conn, 200) =~ "Edit retrospective"
    end

    test "updates other user's retrospective and redirects when data is valid", %{conn: conn} do
      user = insert(:user)
      group = insert(:group, %{owner: user})
      pair = insert(:pair, %{group: group, users: [user]})
      pair_retro = Repo.insert! %PairRetro{user_id: user.id, pair_id: pair.id}

      attrs = Map.merge(@valid_attrs, %{pair_id: pair.id, user_id: user.id})

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
