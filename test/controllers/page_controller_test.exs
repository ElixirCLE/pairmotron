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
      {year, week} = Timex.iso_week(Timex.today)
      conn = get build_conn, page_path(build_conn, :show, year, week)
      {:ok, [conn: conn, usera: usera, userb: userb]}
    end

    test "displays the users that were paired", %{conn: conn, usera: usera, userb: userb} do
      assert html_response(conn, 200) =~ usera.name
      assert html_response(conn, 200) =~ userb.name
    end

    test "does not display a user added after first pairing", %{conn: conn} do
      {:ok, userc} = Pairmotron.Repo.insert(%Pairmotron.User{name: "userc", email: "c", active: true})
      {year, week} = Timex.iso_week(Timex.today)
      conn = get conn, page_path(conn, :show, year, week)
      refute html_response(conn, 200) =~ userc.name
    end

    test "repairifies", %{conn: conn} do
      {:ok, userc} = Pairmotron.Repo.insert(%Pairmotron.User{name: "userc", email: "c", active: true})
      {year, week} = Timex.iso_week(Timex.today)
      conn = delete conn, page_path(conn, :delete, year, week)
      conn = get conn, page_path(conn, :show, year, week)
      assert html_response(conn, 200) =~ userc.name
    end

    test "does not pairify for a week that is not current", %{conn: conn, usera: usera, userb: userb} do
      conn = get conn, page_path(conn, :show, 1999, 1)
      refute html_response(conn, 200) =~ usera.name
      refute html_response(conn, 200) =~ userb.name
    end
  end
end
