defmodule Pairmotron.UserGroupTest do
  use Pairmotron.ModelCase

  alias Pairmotron.UserGroup

  describe "changeset/2" do
    test "with valid attributes is valid" do
      changeset = UserGroup.changeset(%UserGroup{}, %{user_id: 1, group_id: 1})
      assert changeset.valid?
    end

    test "invalid without user_id" do
      changeset = UserGroup.changeset(%UserGroup{}, %{group_id: 1})
      refute changeset.valid?
    end

    test "invalid without group_id" do
      changeset = UserGroup.changeset(%UserGroup{}, %{user_id: 1})
      refute changeset.valid?
    end
  end

  describe "user_group_for_user_and_group/2" do
    test "returns user_group with :user and :group preloaded when it exists" do
      user = insert(:user)
      group = insert(:group, %{users: [user]})
      user_group = UserGroup.user_group_for_user_and_group(user.id, group.id) |> Repo.one
      refute is_nil(user_group)
      assert Ecto.assoc_loaded?(user_group.user)
      assert Ecto.assoc_loaded?(user_group.group)
    end

    test "returns user_group with :user and :group preloaded when it exists and ids are binaries" do
      user = insert(:user)
      group = insert(:group, %{users: [user]})
      user_group = UserGroup.user_group_for_user_and_group(Integer.to_string(user.id), Integer.to_string(group.id)) |> Repo.one
      refute is_nil(user_group)
      assert Ecto.assoc_loaded?(user_group.user)
      assert Ecto.assoc_loaded?(user_group.group)
    end

    test "returns nil if user is not in group" do
      user = insert(:user)
      group = insert(:group)
      user_group = UserGroup.user_group_for_user_and_group(user.id, group.id) |> Repo.one
      assert is_nil(user_group)
    end

    test "returns nil if user does not exist" do
      group = insert(:group)
      user_group = UserGroup.user_group_for_user_and_group(123, group.id) |> Repo.one
      assert is_nil(user_group)
    end

    test "returns nil if group does not exist" do
      user = insert(:user)
      user_group = UserGroup.user_group_for_user_and_group(user.id, 123) |> Repo.one
      assert is_nil(user_group)
    end
  end
end
