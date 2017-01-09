defmodule Pairmotron.RoleTest do
  use Pairmotron.ModelCase

  alias Pairmotron.Role

  @valid_attrs %{is_admin: true, name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Role.changeset(%Role{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Role.changeset(%Role{}, @invalid_attrs)
    refute changeset.valid?
  end
end
