defmodule Pairmotron.PairRetroViewTest do
  use Pairmotron.ConnCase, async: true
  alias Pairmotron.PairRetroView

  test "returns an empty array when there is no projects field in the conn assign" do
    conn = build_conn()
    assert PairRetroView.projects_for_select(conn) == []
  end

  test "returns an array of projects when there are projects in the conn assign" do
    conn = build_conn()
    project = insert(:project)
    conn = Plug.Conn.assign(conn, :projects, [project])
    expected_projects = ["#{project.name}": project.id]
    assert PairRetroView.projects_for_select(conn) == expected_projects
  end
end
