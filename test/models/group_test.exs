defmodule Pairmotron.GroupTest do
  use Pairmotron.ModelCase

  alias Pairmotron.Group

  @valid_attrs %{name: "some content", owner_id: 1, description: "group description"}
  @invalid_attrs %{}

  @invalid_period_length %{name: "s", owner_id: 1, description: "d", period_length: 5}

  describe "anchor/0" do
    test "provides a Monday" do
      group = insert(:group)
      assert 1 = Date.day_of_week(group.anchor)
    end
  end

  describe "changeset/2" do
    test "with valid attributes" do
      changeset = Group.changeset(%Group{}, @valid_attrs)
      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = Group.changeset(%Group{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "with invalid period_length" do
      changeset = Group.changeset(%Group{}, @invalid_period_length)
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

  describe "group_with_users/1" do
    test "returns group with users preloaded" do
      user = insert(:user)
      group = insert(:group, %{users: [user]})

      returned_group = Group.group_with_users(group.id) |> Repo.one
      assert returned_group.id == group.id
      assert Ecto.assoc_loaded?(returned_group.users)
      [returned_user] = returned_group.users
      assert returned_user.id == user.id
    end

    test "returns group when the group has no users" do
      group = insert(:group)
      assert Repo.one(Group.group_with_users(group.id))
    end

    test "returns nil when group doesn't exist" do
      assert is_nil(Repo.one(Group.group_with_users(123)))
    end
  end

  describe "group_with_owner_and_users/1" do
    test "returns group with users and owner preloaded" do
      owner_user = insert(:user)
      user = insert(:user)
      group = insert(:group, %{owner: owner_user, users: [user]})

      returned_group = Group.group_with_owner_and_users(group.id) |> Repo.one
      assert returned_group.id == group.id
      assert Ecto.assoc_loaded?(returned_group.owner)
      assert returned_group.owner.id == owner_user.id
      assert Ecto.assoc_loaded?(returned_group.users)
      [returned_user] = returned_group.users
      assert returned_user.id == user.id
    end

    test "returns group when the group has no owner" do
      user = insert(:user)
      group = insert(:group, %{owner: nil, users: [user]})
      assert Repo.one(Group.group_with_owner_and_users(group.id))
    end

    test "returns group when the group has no users" do
      user = insert(:user)
      group = insert(:group, %{owner: user})
      assert Repo.one(Group.group_with_owner_and_users(group.id))
    end

    test "returns group when the group has no owner or users" do
      group = insert(:group, %{owner: nil})
      assert Repo.one(Group.group_with_owner_and_users(group.id))
    end

    test "returns nil when group doesn't exist" do
      assert is_nil(Repo.one(Group.group_with_owner_and_users(123)))
    end
  end
end
