defmodule Pairmotron.PairerTest do
  use ExUnit.Case, async: true

  alias Pairmotron.{Pairer, User, UserPair}

  @user_1 %User{id: 1}
  @user_2 %User{id: 2}
  @user_3 %User{id: 3}
  @user_4 %User{id: 4}
  @user_5 %User{id: 5}

  @user_pair_1 %UserPair{pair_id: 1, user_id: 1}
  @user_pair_2 %UserPair{pair_id: 1, user_id: 2}
  @user_pair_3 %UserPair{pair_id: 2, user_id: 3}
  @user_pair_4 %UserPair{pair_id: 2, user_id: 4}

  @user_pair_changeset UserPair.changeset(%UserPair{}, %{pair_id: 2, user_id: 5})

  describe ".generate_pairs/1" do
    test "empty list of users returns empty list" do
      assert %PairerResult{pairs: []} = Pairer.generate_pairs([])
    end

    test "list of one user returns a pair of that user" do
      assert %PairerResult{pairs: [[@user_1]]} == Pairer.generate_pairs([@user_1])
    end

    test "list of two users returns a pair of those users" do
      assert %PairerResult{pairs: [first_pair]} = Pairer.generate_pairs([@user_1, @user_2])
      assert Enum.sort(first_pair) == [@user_1, @user_2]
    end

    test "list of four users returns two pairs of those users" do
      assert %PairerResult{pairs: [first_pair, second_pair]} = Pairer.generate_pairs([@user_1, @user_2, @user_3, @user_4])
      assert Enum.sort(first_pair) == [@user_1, @user_2]
      assert Enum.sort(second_pair) == [@user_3, @user_4]
    end

    test "list of three users returns one pair of those three users" do
      assert %PairerResult{pairs: [first_pair]} = Pairer.generate_pairs([@user_1, @user_2, @user_3])
      assert Enum.sort(first_pair) == [@user_1, @user_2, @user_3]
    end

    test "list of five users returns two pairs with the three person pair at the end" do
      assert %PairerResult{pairs: [first_pair, second_pair]} = Pairer.generate_pairs([@user_1, @user_2, @user_3, @user_4, @user_5])
      assert Enum.sort(first_pair) == [@user_1, @user_2]
      assert Enum.sort(second_pair) == [@user_3, @user_4, @user_5]
    end
  end

  describe ".generate_pairs/2" do
    test "empty list of users and empty user pairs returns empty list" do
      assert %PairerResult{user_pair: nil, pairs: []} = Pairer.generate_pairs([], [])
    end

    test "some users and an empty list of user pairs pairs the users" do
      assert %PairerResult{pairs: [first_pair]} = Pairer.generate_pairs([@user_1, @user_2], [])
      assert Enum.sort(first_pair) == [@user_1, @user_2]
    end

    test "new users with existing pairs pairs the new users" do
      assert %PairerResult{pairs: [first_pair]} = Pairer.generate_pairs([@user_3, @user_4], [@user_pair_1, @user_pair_2])
      assert Enum.sort(first_pair) == [@user_3, @user_4]
    end

    test "single new user with exist pair gets placed with the pair" do
      assert %PairerResult{user_pair: @user_pair_changeset} = Pairer.generate_pairs([@user_5], [@user_pair_3, @user_pair_4])
    end
  end
end
