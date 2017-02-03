defmodule Pairmotron.PairBuilderTest do
  use ExUnit.Case, async: true

  alias Pairmotron.{PairBuilder, User, Pair, UserPair}

  @user_1 %User{id: 1}
  @user_2 %User{id: 2}
  @user_3 %User{id: 3}
  @user_4 %User{id: 4}
  @user_5 %User{id: 5}

  @pair_1 %Pair{id: 1}
  @pair_2 %Pair{id: 2}

  @user_pair_1 %UserPair{id: 1, pair: @pair_1, user: @user_1}
  @user_pair_2 %UserPair{id: 2, pair: @pair_1, user: @user_2}
  @user_pair_3 %UserPair{id: 3, pair: @pair_2, user: @user_3}
  @user_pair_4 %UserPair{id: 4, pair: @pair_2, user: @user_4}

  describe ".determify/2" do
    test "empty user pairs and users" do
      assert %Determination{dead_pairs: [], remaining_user_pairs: [], available_users: []} = PairBuilder.determify([], [])
    end

    test "empty user pairs and some users" do
      determination = PairBuilder.determify([], [@user_1, @user_3])
      assert determination.dead_pairs == []
      assert determination.remaining_user_pairs == []
      assert determination.available_users |> Enum.sort == [@user_1, @user_3]
    end
  end

  describe ".find_dead_user_pairs/2" do
    test "empty user pairs and users" do
      assert [] = PairBuilder.find_dead_user_pairs([], [])
    end

    test "empty user pairs and some users" do
      assert [] = PairBuilder.find_dead_user_pairs([], [@user_1, @user_2])
    end

    test "matching user pairs and users" do
      assert [] = PairBuilder.find_dead_user_pairs([@user_pair_1, @user_pair_2], [@user_1, @user_2])
    end

    test "1 user is now inactive" do
      user_pairs = PairBuilder.find_dead_user_pairs([@user_pair_1, @user_pair_2], [@user_1])
      assert Enum.sort(user_pairs) == [@user_pair_1, @user_pair_2]
    end

    test "both are now inactive" do
      user_pairs = PairBuilder.find_dead_user_pairs([@user_pair_1, @user_pair_2], [])
      assert Enum.sort(user_pairs) == [@user_pair_1, @user_pair_2]
    end

    test "some users are now inactive" do
      user_pairs = PairBuilder.find_dead_user_pairs([@user_pair_1, @user_pair_2, @user_pair_3, @user_pair_4], [@user_1, @user_3])
      assert Enum.sort(user_pairs) == [@user_pair_1, @user_pair_2, @user_pair_3, @user_pair_4]
    end
  end

  describe ".find_users_to_pair/2" do
    test "empty user pairs and users" do
      assert [] = PairBuilder.find_users_to_pair([], [])
    end

    test "empty user pairs and some users" do
      users = PairBuilder.find_users_to_pair([], [@user_1, @user_2])
      assert Enum.sort(users) == [@user_1, @user_2]
    end

    test "matching user pairs and users" do
      assert [] = PairBuilder.find_users_to_pair([@user_pair_1, @user_pair_2], [@user_1, @user_2])
    end

    test "1 user is now inactive" do
      assert [@user_1] = PairBuilder.find_users_to_pair([@user_pair_1, @user_pair_2], [@user_1])
    end

    test "both users are now inactive" do
      assert [] = PairBuilder.find_users_to_pair([@user_pair_1, @user_pair_2], [])
    end

    test "some users are now inactive" do
      users = PairBuilder.find_users_to_pair([@user_pair_1, @user_pair_2, @user_pair_3, @user_pair_4], [@user_1, @user_3, @user_4])
      assert Enum.sort(users) == [@user_1]
    end

    test "some new users are available" do
      users = PairBuilder.find_users_to_pair([@user_pair_1, @user_pair_2], [@user_1, @user_2, @user_3, @user_4])
      assert Enum.sort(users) == [@user_3, @user_4]
    end
  end

  describe ".find_dead_pairs/2" do
    test "empty user pairs and users" do
      assert [] = PairBuilder.find_dead_pairs([], [])
    end

    test "empty user pairs and some users" do
      assert [] = PairBuilder.find_dead_pairs([], [@user_1, @user_2])
    end

    test "matching user pairs and users" do
      assert [] = PairBuilder.find_dead_pairs([@user_pair_1, @user_pair_2], [@user_1, @user_2])
    end

    test "1 user is now inactive" do
      pairs = PairBuilder.find_dead_pairs([@user_pair_1, @user_pair_2], [@user_1])
      assert Enum.sort(pairs) == [@pair_1]
    end

    test "both users are now inactive" do
      pairs = PairBuilder.find_dead_pairs([@user_pair_1, @user_pair_2], [])
      assert Enum.sort(pairs) == [@pair_1]
    end

    test "some users are now inactive" do
      pairs = PairBuilder.find_dead_pairs([@user_pair_1, @user_pair_2, @user_pair_3, @user_pair_4], [@user_1, @user_3])
      assert Enum.sort(pairs) == [@pair_1, @pair_2]
    end
  end
end
