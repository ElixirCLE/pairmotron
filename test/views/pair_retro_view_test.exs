defmodule Pairmotron.PairRetroViewTest do
  use Pairmotron.ConnCase, async: true
  alias Pairmotron.PairRetroView

  describe "projects_as_select/1" do
    test "returns an empty array when given an empty array of projects" do
      assert PairRetroView.projects_as_select([]) == []
    end

    test "return an array formatted for a dropdown when given an array of projects" do
      project_1 = build(:project, %{id: 1})
      project_2 = build(:project, %{id: 2})
      projects = [project_1, project_2]
      expected_projects = ["#{project_1.name}": project_1.id,
                           "#{project_2.name}": project_2.id]
      assert PairRetroView.projects_as_select(projects) == expected_projects
    end
  end
end
