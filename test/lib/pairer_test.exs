defmodule Pairmotron.PairerTest do
  use ExUnit.Case, async: true
    
  alias Pairmotron.Pairer
  alias Pairmotron.User

  @user_1 %User{id: 1}
  @user_2 %User{id: 2}
  @user_3 %User{id: 3}
  @user_4 %User{id: 4}
  @user_5 %User{id: 5}

  describe ".generate_pairs" do
    test "empty list of users returns empty list" do
      assert Pairer.generate_pairs([]) == []
    end

    test "list of one user returns a pair of that user" do
      assert Pairer.generate_pairs( [@user_1] ) == [ [@user_1] ]
    end

    test "list of two users returns a pair of those users" do
      assert [first_pair] = Pairer.generate_pairs([@user_1, @user_2])
      assert Enum.sort(first_pair) == [@user_1, @user_2]
    end

    test "list of four users returns two pairs of those users" do
      assert [first_pair, second_pair] = Pairer.generate_pairs([@user_1, @user_2, @user_3, @user_4])
      assert Enum.sort(first_pair) == [@user_1, @user_2]
      assert Enum.sort(second_pair) == [@user_3, @user_4]
    end

    test "list of three users returns one pair of those three users" do
      assert [first_pair] = Pairer.generate_pairs([@user_1, @user_2, @user_3])
      assert Enum.sort(first_pair) == [@user_1, @user_2, @user_3]
    end

    test "list of five users returns two pairs with the three person pair at the end" do
      assert [first_pair, second_pair] = Pairer.generate_pairs([@user_1, @user_2, @user_3, @user_4, @user_5])
      assert Enum.sort(first_pair) == [@user_1, @user_2]
      assert Enum.sort(second_pair) == [@user_3, @user_4, @user_5]
    end
  end
end
