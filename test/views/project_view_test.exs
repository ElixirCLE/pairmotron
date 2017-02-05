defmodule Pairmotron.ProjectViewTest do
  use Pairmotron.ConnCase, async: true
  alias Pairmotron.ProjectView

  describe ".user_can_edit_project?" do
    test "creator of project can edit project" do
      user = insert(:user)
      project = insert(:project, %{created_by: user})
      assert ProjectView.user_can_edit_project?(project, user) == true
    end

    test "owner of project's group can edit project" do
      user = insert(:user)
      group = insert(:group, %{owner: user, users: [user]})
      project = insert(:project, %{group: group})
      assert ProjectView.user_can_edit_project?(project, user) == true
    end

    test "regular user in group cannot edit project when not creator" do
      user = insert(:user)
      group = insert(:group, %{users: [user]})
      project = insert(:project, %{group: group})
      assert ProjectView.user_can_edit_project?(project, user) == false
    end
  end
end
