defmodule Pairmotron.PageViewTest do
  use Pairmotron.ConnCase, async: true
  import Pairmotron.TestHelper, only: [log_in: 2, create_pair: 1]
  alias Pairmotron.PageView

  describe ".current_user_in_pair" do
    test "is false when the logged in user is not in the pair" do
      logged_in_user = insert(:user)
      other_user = insert(:user)
      pair = create_pair([other_user]) |> Pairmotron.Repo.preload([:users])
      conn = build_conn |> log_in(logged_in_user)
      refute PageView.current_user_in_pair(conn, pair)
    end

    test "is true when the logged in user is in the pair" do
      user = insert(:user)
      pair = create_pair([user]) |> Pairmotron.Repo.preload([:users])
      conn = build_conn |> log_in(user)
      assert PageView.current_user_in_pair(conn, pair)
    end

    test "is false when no user is logged in" do
      user = insert(:user)
      pair = create_pair([user])
      conn = build_conn
      refute PageView.current_user_in_pair(conn, pair)
    end
  end
end
