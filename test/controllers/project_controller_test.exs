defmodule Pairmotron.ProjectControllerTest do
  use Pairmotron.ConnCase

  alias Pairmotron.Project
  @valid_attrs %{description: "some content", name: "some content", url: "http://example.org"}
  @invalid_attrs %{url: "nothing"}

  def log_in(conn, user) do
    conn |> Plug.Conn.assign(:current_user, user)
  end

  test "redirects to sign-in when not logged in", %{conn: conn} do
    conn = get conn, project_path(conn, :index)
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
      conn = get conn, project_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing projects"
    end

    test "renders form for new resources", %{conn: conn} do
      conn = get conn, project_path(conn, :new)
      assert html_response(conn, 200) =~ "New project"
    end

    test "creates resource and redirects when data is valid", %{conn: conn} do
      conn = post conn, project_path(conn, :create), project: @valid_attrs
      assert redirected_to(conn) == project_path(conn, :index)
      assert Repo.get_by(Project, @valid_attrs)
    end

    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      conn = post conn, project_path(conn, :create), project: @invalid_attrs
      assert html_response(conn, 200) =~ "New project"
    end

    test "shows chosen resource", %{conn: conn} do
      project = Repo.insert! %Project{}
      conn = get conn, project_path(conn, :show, project)
      assert html_response(conn, 200) =~ "Show project"
    end

    test "renders page not found when id is nonexistent", %{conn: conn} do
      assert_error_sent 404, fn ->
        get conn, project_path(conn, :show, -1)
      end
    end

    test "renders form for editing chosen resource", %{conn: conn} do
      project = Repo.insert! %Project{}
      conn = get conn, project_path(conn, :edit, project)
      assert html_response(conn, 200) =~ "Edit project"
    end

    test "updates chosen resource and redirects when data is valid", %{conn: conn} do
      project = Repo.insert! %Project{}
      conn = put conn, project_path(conn, :update, project), project: @valid_attrs
      assert redirected_to(conn) == project_path(conn, :show, project)
      assert Repo.get_by(Project, @valid_attrs)
    end

    test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
      project = Repo.insert! %Project{}
      conn = put conn, project_path(conn, :update, project), project: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit project"
    end

    test "deletes chosen resource", %{conn: conn} do
      project = Repo.insert! %Project{}
      conn = delete conn, project_path(conn, :delete, project)
      assert redirected_to(conn) == project_path(conn, :index)
      refute Repo.get(Project, project.id)
    end
  end
end
