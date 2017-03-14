defmodule Pairmotron.GroupTest do
  use Pairmotron.ModelCase

  alias Pairmotron.Group

  @valid_attrs %{name: "some content", owner_id: 1, description: "group description"}
  @invalid_attrs %{}

  describe "changeset/2" do
    test "with valid attributes" do
      changeset = Group.changeset(%Group{}, @valid_attrs)
      assert changeset.valid?
    end

    test " with invalid attributes" do
      changeset = Group.changeset(%Group{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "sanitizes name" do
      changeset = Group.changeset(%Group{}, %{name: "<h1>name</h1>", owner_id: 1})
      assert changeset.valid?
      assert "name" == changeset.changes.name
    end

    test "sanitizes description" do
      changeset = Group.changeset(%Group{}, %{name: "name", owner_id: 1, description: "<div><p>description</p></div>"})
      assert changeset.valid?
      assert "description" == changeset.changes.description
    end
  end

  describe "changeset_for_create/3" do
    test "with valid attributes" do
      changeset = Group.changeset_for_create(%Group{}, @valid_attrs, [%{id: 1}])
      assert changeset.valid?
    end
  end
end
