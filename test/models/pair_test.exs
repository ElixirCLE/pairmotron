defmodule Pairmotron.PairTest do
  use Pairmotron.ModelCase
  alias Pairmotron.Pair

  @valid_attrs %{group_id: 42, week: 42, year: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Pair.changeset(%Pair{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Pair.changeset(%Pair{}, @invalid_attrs)
    refute changeset.valid?
  end
end
