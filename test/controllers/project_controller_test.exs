defmodule Pairmotron.ProjectControllerTest do
  use Pairmotron.ConnCase

  alias Pairmotron.Project
  import Pairmotron.TestHelper, only: [log_in: 2, create_pair: 1, create_retro: 3]

  @valid_attrs %{description: "some content", name: "some content", url: "http://example.org"}
  @invalid_attrs %{url: "nothing"}

  test "redirects to sign-in when not logged in", %{conn: conn} do
    conn = get conn, project_path(conn, :index)
    assert redirected_to(conn) == session_path(conn, :new)
  end

  describe "while authenticated" do
    setup do
      user = insert(:user)
      conn = build_conn() |> log_in(user)
      {:ok, [conn: conn, logged_in_user: user]}
    end

    test "lists all entries on index", %{conn: conn} do
      conn = get conn, project_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing projects"
    end

    test "lists group name associated with a project", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{users: [user]})
      insert(:project, %{group: group})
      conn = get conn, project_path(conn, :index)
      assert html_response(conn, 200) =~ group.name
    end

    test "links to edit of project if user is owner project's group", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      project = insert(:project, %{group: group})
      conn = get conn, project_path(conn, :index)
      assert html_response(conn, 200) =~ project_path(conn, :edit, project)
    end

    test "does not link to edit of project if user is not owner of project's group",
      %{conn: conn, logged_in_user: user} do
      group = insert(:group, users: [user])
      project = insert(:project, %{group: group})
      conn = get conn, project_path(conn, :index)
      refute html_response(conn, 200) =~ project_path(conn, :edit, project)
    end

    test "does not list project associated with group user is not member of", %{conn: conn} do
      group = insert(:group)
      project = insert(:project, %{group: group})
      conn = get conn, project_path(conn, :index)
      refute html_response(conn, 200) =~ project.name
    end

    test "renders links to create and edit group if user is not in a group", %{conn: conn} do
      conn = get conn, project_path(conn, :new)
      assert html_response(conn, 200) =~ group_path(conn, :new)
      assert html_response(conn, 200) =~ group_path(conn, :index)
    end

    test "renders form for new resource if user is in any group", %{conn: conn, logged_in_user: user} do
      insert(:group, %{owner: user, users: [user]})
      conn = get conn, project_path(conn, :new)
      assert html_response(conn, 200) =~ "New project"
    end

    test "creates resource and redirects when data is valid", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      valid_attrs = Map.put(@valid_attrs, :group_id, group.id)
      conn = post conn, project_path(conn, :create), project: valid_attrs
      assert redirected_to(conn) == project_path(conn, :index)
      assert Repo.get_by(Project, valid_attrs)
    end

    test "does not create project if user is not in project's group", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: []})
      attrs = Map.put(@valid_attrs, :group_id, group.id)
      conn = post conn, project_path(conn, :create), project: attrs
      assert html_response(conn, 200) =~ "New project"
      refute Repo.get_by(Project, attrs)
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

    test "allows edit of project if user is owner of associated group", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      project = insert(:project, %{group: group})
      conn = get conn, project_path(conn, :edit, project)
      assert html_response(conn, 200) =~ "Edit project"
    end

    test "does not allow edit of project if user is in associated group but not owner", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{users: [user]})
      project = insert(:project, %{group: group})
      conn = get conn, project_path(conn, :edit, project)
      assert redirected_to(conn) == project_path(conn, :index)
    end

    test "does not allow edit of project if user is not associated with project group", %{conn: conn} do
      group = insert(:group)
      project = insert(:project, %{group: group})
      conn = get conn, project_path(conn, :edit, project)
      assert redirected_to(conn) == project_path(conn, :index)
    end

    test "does not allow edit of project if it has no group", %{conn: conn} do
      project = insert(:project)
      conn = get conn, project_path(conn, :edit, project)
      assert redirected_to(conn) == project_path(conn, :index)
    end

    test "updates project if user is owner of associated group", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      project = insert(:project, %{group: group})
      conn = put conn, project_path(conn, :update, project), project: @valid_attrs
      assert redirected_to(conn) == project_path(conn, :show, project)
      assert Repo.get_by(Project, @valid_attrs)
    end

    test "cannot update project to have new group", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      project = insert(:project, %{group: group})
      other_group = insert(:group, %{owner: user, users: [user]})
      put conn, project_path(conn, :update, project), project: %{group_id: other_group.id}
      updated_project = Repo.get(Project, project.id)
      assert updated_project.group_id == group.id
    end

    test "does not update project if user is in associated group but not owner", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{users: [user]})
      project = insert(:project, %{group: group})
      conn = put conn, project_path(conn, :update, project), project: @valid_attrs
      assert redirected_to(conn) == project_path(conn, :index)
      refute Repo.get_by(Project, @valid_attrs)
    end

    test "does not update project if user is not associated with project group", %{conn: conn} do
      group = insert(:group)
      project = insert(:project, %{group: group})
      conn = put conn, project_path(conn, :update, project), project: @valid_attrs
      assert redirected_to(conn) == project_path(conn, :index)
      refute Repo.get_by(Project, @valid_attrs)
    end

    test "does not update project if it has no group", %{conn: conn} do
      project = insert(:project)
      conn = put conn, project_path(conn, :update, project), project: @valid_attrs
      assert redirected_to(conn) == project_path(conn, :index)
      refute Repo.get_by(Project, @valid_attrs)
    end

    test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      project = insert(:project, %{group: group})
      conn = put conn, project_path(conn, :update, project), project: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit project"
    end

    test "deletes project if user is owner of associated group", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      project = insert(:project, %{group: group})
      conn = delete conn, project_path(conn, :delete, project)
      assert redirected_to(conn) == project_path(conn, :index)
      refute Repo.get(Project, project.id)
    end

    test "does not delete project if user is in associated group but not owner", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{users: [user]})
      project = insert(:project, %{group: group})
      conn = delete conn, project_path(conn, :delete, project)
      assert redirected_to(conn) == project_path(conn, :index)
      assert Repo.get(Project, project.id)
    end

    test "does not delete project if user is not associated with project group", %{conn: conn} do
      group = insert(:group)
      project = insert(:project, %{group: group})
      conn = delete conn, project_path(conn, :delete, project)
      assert redirected_to(conn) == project_path(conn, :index)
      assert Repo.get(Project, project.id)
    end

    test "does not delete project if it has no group", %{conn: conn} do
      project = insert(:project)
      conn = delete conn, project_path(conn, :delete, project)
      assert redirected_to(conn) == project_path(conn, :index)
      assert Repo.get(Project, project.id)
    end

    test "can delete project when a retro references it", %{conn: conn, logged_in_user: user} do
      group = insert(:group, %{owner: user, users: [user]})
      project = insert(:project, %{group: group})
      pair = create_pair([user])
      create_retro(user, pair, project)
      conn = delete conn, project_path(conn, :delete, project)
      assert redirected_to(conn) == project_path(conn, :index)
      refute Repo.get(Project, project.id)
    end
  end
end
