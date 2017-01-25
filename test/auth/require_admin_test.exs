defmodule Pairmotron.RequireAdminTest do
  use Pairmotron.ConnCase

  import Pairmotron.TestHelper, only: [log_in: 2]

  describe "while authenticated" do
    setup do
      user = insert(:user)
      conn = build_conn
        |> log_in(user)
      {:ok, [conn: conn, logged_in_user: user]}
    end
    test "redirects when user is not an admin ", %{conn: conn, logged_in_user: user} do
      conn = conn |> Pairmotron.RequireAdmin.call(user)
      assert redirected_to(conn) == "/pairs"
    end
  end

  describe "as admin" do
    setup do
      user = insert(:user_admin)
      conn = build_conn
        |> log_in(user)
      {:ok, [conn: conn, logged_in_user: user]}
    end
    test "passes through when user is an admin", %{conn: conn, logged_in_user: user} do
      res_conn = conn |> Pairmotron.RequireAdmin.call(user)
      assert res_conn == conn
    end
  end
end
