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
end
