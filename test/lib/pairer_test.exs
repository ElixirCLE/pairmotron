defmodule Pairmotron.PairerTest do
  use ExUnit.Case, async: true

  alias Pairmotron.{Pairer, User, UserPair, Pair}

  @user_1 %User{id: 1}
  @user_2 %User{id: 2}
  @user_3 %User{id: 3}
  @user_4 %User{id: 4}
  @user_5 %User{id: 5}
  @user_6 %User{id: 6}

  @pair1 %Pair{id: 1, users: [@user_1, @user_2]}
  @pair2 %Pair{id: 2, users: [@user_1, @user_2, @user_3]}
  @pair3 %Pair{id: 3, users: [@user_1]}

  @user_pair_changeset UserPair.changeset(%UserPair{}, %{pair_id: 1, user_id: 5})
  @user_pair_changeset2 UserPair.changeset(%UserPair{}, %{pair_id: 3, user_id: 5})

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
      assert %PairerResult{pairs: [first_pair]} = Pairer.generate_pairs([@user_3, @user_4], [@pair1])
      assert Enum.sort(first_pair) == [@user_3, @user_4]
    end

    test "single new user with existing pair gets placed with the existing pair" do
      assert %PairerResult{user_pair: @user_pair_changeset} = Pairer.generate_pairs([@user_5], [@pair1])
    end

    test "single new user with existing 3-pair gets placed in their own single-pair" do
      assert %PairerResult{pairs: [[@user_5]]} = Pairer.generate_pairs([@user_5], [@pair2])
    end

    test "single new user with existing 2- and 3-pair gets placed with the 2-pair" do
      assert %PairerResult{user_pair: @user_pair_changeset} = Pairer.generate_pairs([@user_5], [@pair1, @pair2])
    end

    test "single new user with existing 3- and 3-pair gets placed in a new pair" do
      assert %PairerResult{pairs: [[@user_5]]} = Pairer.generate_pairs([@user_5], [@pair2, @pair2])
    end

    test "single new user with existing 1-, 2-, and 3-pair gets placed with the 1-pair" do
      assert %PairerResult{user_pair: @user_pair_changeset2} = Pairer.generate_pairs([@user_5], [@pair1, @pair2, @pair3])
    end

    test "two new users with existing pair get matched as a new pair" do
      assert %PairerResult{pairs: [[@user_3, @user_4]]} = Pairer.generate_pairs([@user_3, @user_4], [@pair1])
    end

    test "three new users with existing pair get matched as a new three pair" do
      %PairerResult{pairs: [users]} = Pairer.generate_pairs([@user_3, @user_4, @user_5], [@pair1])
      assert Enum.sort(users) == [@user_3, @user_4, @user_5]
    end

    test "four new users with an existing pair get matched as two new pairs" do
      assert %PairerResult{pairs: [[@user_3, @user_4], [@user_5, @user_6]]} = Pairer.generate_pairs([@user_3, @user_4, @user_5, @user_6], [@pair1])
    end
  end
end
