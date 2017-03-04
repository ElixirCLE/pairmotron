defmodule Pairmotron.ProjectTest do
  use Pairmotron.ModelCase

  alias Pairmotron.Project

  @valid_attrs %{name: "some content", url: "http://example.org"}
  @invalid_attrs %{url: "nothing"}

  test "changeset with valid attributes" do
    changeset = Project.changeset(%Project{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Project.changeset(%Project{}, @invalid_attrs)
    refute changeset.valid?
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
