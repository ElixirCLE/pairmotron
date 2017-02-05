defmodule Pairmotron.PairBuilderTest do
  use ExUnit.Case, async: true

  alias Pairmotron.{PairBuilder, User, Pair}

  @user_1 %User{id: 1}
  @user_2 %User{id: 2}
  @user_3 %User{id: 3}
  @user_4 %User{id: 4}

  @pair_1 %Pair{id: 1, users: [@user_1, @user_2]}
  @pair_2 %Pair{id: 2, users: [@user_3, @user_4]}

  describe ".determify/2" do
    test "empty pairs and users" do
      assert %Determination{} = PairBuilder.determify([], [])
    end

    test "empty pairs and some users" do
      determination = PairBuilder.determify([], [@user_1, @user_3])
      assert determination.dead_pairs |> Enum.sort == []
      assert determination.remaining_pairs |> Enum.sort == []
      assert determination.available_users |> Enum.sort == [@user_1, @user_3]
    end

    test "matching pairs and users" do
      determination = PairBuilder.determify([@pair_1], [@user_1, @user_2])
      assert determination.dead_pairs |> Enum.sort == []
      assert determination.remaining_pairs |> Enum.sort == [@pair_1]
      assert determination.available_users |> Enum.sort == []
    end

    test "1 user is now inactive" do
      determination = PairBuilder.determify([@pair_1], [@user_1])
      assert determination.dead_pairs |> Enum.sort == [@pair_1]
      assert determination.remaining_pairs |> Enum.sort == []
      assert determination.available_users |> Enum.sort == [@user_1]
    end

    test "both users are now inactive" do
      determination = PairBuilder.determify([@pair_1], [])
      assert determination.dead_pairs |> Enum.sort == [@pair_1]
      assert determination.remaining_pairs |> Enum.sort == []
      assert determination.available_users |> Enum.sort == []
    end

    test "some users are now inactive" do
      determination = PairBuilder.determify([@pair_1, @pair_2], [@user_1, @user_3])
      assert determination.dead_pairs |> Enum.sort == [@pair_1, @pair_2]
      assert determination.remaining_pairs |> Enum.sort == []
      assert determination.available_users |> Enum.sort == [@user_1, @user_3]
    end

    test "1 pair is broken up" do
      determination = PairBuilder.determify([@pair_1, @pair_2], [@user_1, @user_2, @user_3])
      assert determination.dead_pairs |> Enum.sort == [@pair_2]
      assert determination.remaining_pairs |> Enum.sort == [@pair_1]
      assert determination.available_users |> Enum.sort == [@user_3]
    end

    test "a new user is available" do
      determination = PairBuilder.determify([@pair_1], [@user_1, @user_2, @user_3])
      assert determination.dead_pairs |> Enum.sort == []
      assert determination.remaining_pairs |> Enum.sort == [@pair_1]
      assert determination.available_users |> Enum.sort == [@user_3]
    end
  end
end
