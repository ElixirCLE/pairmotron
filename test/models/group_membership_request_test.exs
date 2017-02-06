defmodule Pairmotron.GroupMembershipRequestTest do
  use Pairmotron.ModelCase

  alias Pairmotron.GroupMembershipRequest

  @valid_attrs %{initiated_by_user: true}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    user = insert(:user)
    group = insert(:group)
    attrs = Map.merge(@valid_attrs, %{user_id: user.id, group_id: group.id})
    changeset = GroupMembershipRequest.changeset(%GroupMembershipRequest{}, attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = GroupMembershipRequest.changeset(%GroupMembershipRequest{}, @invalid_attrs)
    refute changeset.valid?
  end
end
