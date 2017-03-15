defmodule Pairmotron.ProjectTest do
  use Pairmotron.ModelCase

  alias Pairmotron.Project

  @valid_attrs %{name: "some content", url: "http://example.org"}
  @invalid_attrs %{url: "nothing"}

  describe "changeset" do
    test "changeset with valid attributes" do
      changeset = Project.changeset(%Project{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = Project.changeset(%Project{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "changset sanitizes name" do
      changeset = Project.changeset(%Project{}, %{name: "<h1>name</h1>"})
      assert changeset.valid?
      assert "name" == changeset.changes.name
    end

    test "changset sanitizes description" do
      changeset = Project.changeset(%Project{}, %{name: "test", description: "<p>description</p>"})
      assert changeset.valid?
      assert "description" == changeset.changes.description
    end

    test "changset sanitizes url" do
      changeset = Project.changeset(%Project{}, %{name: "test", url: "http://<script>example</script>.com"})
      assert changeset.valid?
      assert "http://example.com" == changeset.changes.url
    end
  end

  describe "changeset_for_create" do
    test "changeset with valid attributes" do
      user = insert(:user)
      group = insert(:group, %{owner: user, users: [user]})
      attrs = Map.merge(@valid_attrs, %{group_id: group.id, created_by_id: user.id})
      changeset = Project.changeset_for_create(%Project{}, attrs, [group])
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      user = insert(:user)
      group = insert(:group, %{owner: user, users: [user]})
      attrs = Map.merge(@invalid_attrs, %{group_id: group.id, created_by_id: user.id})
      changeset = Project.changeset_for_create(%Project{}, attrs, [group])
      refute changeset.valid?
    end

    test "changset sanitizes name" do
      user = insert(:user)
      group = insert(:group, %{owner: user, users: [user]})
      attrs = Map.merge(@valid_attrs, %{group_id: group.id, created_by_id: user.id, name: "<h1>name</h1>"})
      changeset = Project.changeset_for_create(%Project{}, attrs, [group])
      assert changeset.valid?
      assert "name" == changeset.changes.name
    end

    test "changset sanitizes description" do
      user = insert(:user)
      group = insert(:group, %{owner: user, users: [user]})
      attrs = Map.merge(@valid_attrs, %{group_id: group.id, created_by_id: user.id, description: "<p>description</p>"})
      changeset = Project.changeset_for_create(%Project{}, attrs, [group])
      assert changeset.valid?
      assert "description" == changeset.changes.description
    end

    test "changset sanitizes url" do
      user = insert(:user)
      group = insert(:group, %{owner: user, users: [user]})
      attrs = Map.merge(@valid_attrs, %{group_id: group.id, created_by_id: user.id, url: "http://<script>example</script>.com"})
      changeset = Project.changeset_for_create(%Project{}, attrs, [group])
      assert changeset.valid?
      assert "http://example.com" == changeset.changes.url
    end
  end

  describe "changeset_for_update" do
    test "changeset with valid attributes" do
      user = insert(:user)
      group = insert(:group, %{owner: user, users: [user]})
      attrs = Map.merge(@valid_attrs, %{group_id: group.id, created_by_id: user.id})
      changeset = Project.changeset_for_update(%Project{}, attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      user = insert(:user)
      group = insert(:group, %{owner: user, users: [user]})
      attrs = Map.merge(@invalid_attrs, %{group_id: group.id, created_by_id: user.id})
      changeset = Project.changeset_for_update(%Project{}, attrs)
      refute changeset.valid?
    end

    test "changset sanitizes name" do
      user = insert(:user)
      group = insert(:group, %{owner: user, users: [user]})
      attrs = Map.merge(@valid_attrs, %{group_id: group.id, created_by_id: user.id, name: "<h1>name</h1>"})
      changeset = Project.changeset_for_update(%Project{}, attrs)
      assert changeset.valid?
      assert "name" == changeset.changes.name
    end

    test "changset sanitizes description" do
      user = insert(:user)
      group = insert(:group, %{owner: user, users: [user]})
      attrs = Map.merge(@valid_attrs, %{group_id: group.id, created_by_id: user.id, description: "<p>description</p>"})
      changeset = Project.changeset_for_update(%Project{}, attrs)
      assert changeset.valid?
      assert "description" == changeset.changes.description
    end

    test "changset sanitizes url" do
      user = insert(:user)
      group = insert(:group, %{owner: user, users: [user]})
      attrs = Map.merge(@valid_attrs, %{group_id: group.id, created_by_id: user.id, url: "http://<script>example</script>.com"})
      changeset = Project.changeset_for_update(%Project{}, attrs)
      assert changeset.valid?
      assert "http://example.com" == changeset.changes.url
    end
  end

  describe "projects_for_group" do
    test "returns nothing when there are no projects" do
      assert Project.projects_for_group(1) |> Repo.one == nil
    end

    test "returns a project that is associated with the given group" do
      group = insert(:group)
      project = insert(:project, %{group: group})
      assert Repo.one(Project.projects_for_group(group.id)).id == project.id
    end

    test "does not return a project that is not associated with the given group" do
      insert(:project)
      assert Project.projects_for_group(1) |> Repo.one == nil
    end
  end
end
