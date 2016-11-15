defmodule Pairmotron.PageControllerTest do
  use Pairmotron.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Pairs for"
  end

  test "lists one active user", %{conn: conn} do
    {:ok, user} = Pairmotron.Repo.insert(%Pairmotron.User{name: "junk_name", email: "a", active: true})
    conn = get conn, "/"
    assert html_response(conn, 200) =~ user.name
  end

  test "does not list an inactive user", %{conn: conn} do
    {:ok, user} = Pairmotron.Repo.insert(%Pairmotron.User{name: "junk_name", email: "a", active: false})
    conn = get conn, "/"
    refute html_response(conn, 200) =~ user.name
  end

  describe "pairifying" do
    setup do
      {:ok, usera} = Pairmotron.Repo.insert(%Pairmotron.User{name: "usera", email: "a", active: true})
      {:ok, userb} = Pairmotron.Repo.insert(%Pairmotron.User{name: "userb", email: "b", active: true})
      conn = get build_conn, page_path(build_conn, :show, 2016, 40)
      {:ok, [conn: conn, usera: usera, userb: userb]}
    end

    test "saves and stores the pairs", %{conn: conn, usera: usera, userb: userb} do
      assert html_response(conn, 200) =~ usera.name
      assert html_response(conn, 200) =~ userb.name
      {:ok, userc} = Pairmotron.Repo.insert(%Pairmotron.User{name: "userc", email: "c", active: true})
      conn = get conn, page_path(conn, :show, 2016, 40)
      refute html_response(conn, 200) =~ userc.name
    end

    test "repairifies", %{conn: conn} do
      {:ok, userc} = Pairmotron.Repo.insert(%Pairmotron.User{name: "userc", email: "c", active: true})
      conn = delete conn, page_path(conn, :delete, 2016, 40)
      conn = get conn, page_path(conn, :show, 2016, 40)
      assert html_response(conn, 200) =~ userc.name
    end
  end
end
