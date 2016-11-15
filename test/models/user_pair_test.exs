defmodule Pairmotron.UserPairTest do
  use Pairmotron.ModelCase

  alias Pairmotron.UserPair

  @valid_attrs %{pair_id: 42, user_id: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = UserPair.changeset(%UserPair{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = UserPair.changeset(%UserPair{}, @invalid_attrs)
    refute changeset.valid?
  end
end
