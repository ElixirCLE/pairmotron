defmodule Pairmotron.PairTest do
  use Pairmotron.ModelCase
  alias Pairmotron.Pair

  @valid_attrs %{group_id: 42, week: 42, year: 42}
  @invalid_attrs %{}

  describe "changeset" do
    test "changeset with valid attributes" do
      changeset = Pair.changeset(%Pair{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = Pair.changeset(%Pair{}, @invalid_attrs)
      refute changeset.valid?
    end
  end

  describe "pair_with_users/1" do
    test "returns nil when no pair exists" do
      assert Pair.pair_with_users(1) |> Repo.one == nil
    end

    test "returns the pair if it exists with preloaded users" do
      user = insert(:user)
      pair = insert(:pair, %{users: [user]})

      returned_pair = Pair.pair_with_users(pair.id) |> Repo.one
      assert returned_pair.id == pair.id
      assert Enum.at(returned_pair.users, 0).id == user.id
    end

    test "returns the pair if it exists and there are no associated users" do
      pair = insert(:pair, %{users: []})

      returned_pair = Pair.pair_with_users(pair.id) |> Repo.one
      assert returned_pair.id == pair.id
      assert returned_pair.users == []
    end

    test "returns the pair if given pair_id is binary" do
      pair = insert(:pair, %{users: []})

      returned_pair = Pair.pair_with_users("#{pair.id}") |> Repo.one
      assert returned_pair.id == pair.id
      assert returned_pair.users == []
    end
  end
end
