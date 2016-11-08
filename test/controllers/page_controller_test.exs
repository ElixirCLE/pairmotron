defmodule Pairmotron.PageControllerTest do
  use Pairmotron.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Pairs for"
  end

  test "lists one active user" do
    {:ok, user} = Pairmotron.Repo.insert(%Pairmotron.User{name: "junk_name", email: "a", active: true})
    conn = get conn, "/"
    assert html_response(conn, 200) =~ user.name
  end

  test "does not list an inactive user" do
    {:ok, user} = Pairmotron.Repo.insert(%Pairmotron.User{name: "junk_name", email: "a", active: false})
    conn = get conn, "/"
    refute html_response(conn, 200) =~ user.name
  end
end
