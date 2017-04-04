defmodule Pairmotron.GroupViewTest do
  use Pairmotron.ConnCase, async: true
  alias Pairmotron.GroupView

  describe "truncate/2" do
    test "does nothing to a string shorted than the length" do
      assert GroupView.truncate("short string", 20) == "short string"
    end
    test "shortens and adds ellipses to long strings" do
      assert GroupView.truncate("long string", 6) == "long s..."
    end
    test "ignores nil" do
      assert GroupView.truncate(nil, 5) == nil
    end
  end

  describe "user_group_associated_with_group/2)" do
    test "returns the matching user_group" do
      group = insert(:group)
      user_group1 = insert(:user_group)
      user_group2 = insert(:user_group, %{group: group})
      assert user_group2.id == GroupView.user_group_associated_with_group(group, [user_group1, user_group2]).id
    end

    test "returns nil when passed a nil group" do
      assert nil == GroupView.user_group_associated_with_group(nil, [])
    end

    test "returns nil when no user_group is associated with list" do
      group = insert(:group)
      user_group = insert(:user_group)
      assert nil == GroupView.user_group_associated_with_group(group, [user_group])
    end
  end
end

