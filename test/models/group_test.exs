defmodule Pairmotron.GroupTest do
  use Pairmotron.ModelCase

  alias Pairmotron.Group

  @valid_attrs %{name: "some content", owner_id: 1, description: "group description"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Group.changeset(%Group{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Group.changeset(%Group{}, @invalid_attrs)
    refute changeset.valid?
  end
end
