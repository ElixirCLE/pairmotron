defmodule Pairmotron.PairMakerTest do
  use Pairmotron.ModelCase

  alias Pairmotron.{PairMaker, Pair, UserPair, UserGroup}
  import Pairmotron.TestHelper, only: [ create_retro: 2]

  describe "generate_pairs/3 with group without members" do
    setup do
      user = insert(:user)
      group = insert(:group, %{owner: user})
      {:ok, [user: user, group: group]}
    end
    test "inserts no pairs", %{group: group} do
      PairMaker.generate_pairs(2017, 1, group.id)
      assert [] == Repo.all(Pair)
    end
  end

  describe "generate_pairs/3 with group with member" do
    setup do
      user = insert(:user)
      group = insert(:group, %{owner: user, users: [user]})
      {:ok, [user: user, group: group]}
    end

    test "with no existing pairs inserts 1 pair", %{group: group, user: user} do
      insert(:user)
      PairMaker.generate_pairs(2017, 1, group.id)
      assert [%Pair{}] = Repo.all(Pair)
      [userpair] = Repo.all(UserPair)
      assert user.id == userpair.user_id
    end

    test "with 1 existing valid pair does not destroy the pair", %{user: user} do
      user2 = insert(:user)
      group = insert(:group, %{owner: user, users: [user, user2]})
      existing_pair = Pairmotron.TestHelper.create_pair([user, user2], group, 2017, 1)
      PairMaker.generate_pairs(2017, 1, group.id)
      [pair] = Repo.all(Pair)
      assert existing_pair.id == pair.id
    end

    test "with 1 existing 1-pair destroys the pair", %{group: group, user: user} do
      existing_pair = Pairmotron.TestHelper.create_pair([user], group, 2017, 1)
      PairMaker.generate_pairs(2017, 1, group.id)
      [pair] = Repo.all(Pair)
      assert existing_pair.id != pair.id
    end

    test "with 1 existing valid pair and 1 existing invalid pair destroys the invalid pair", %{user: user} do
      user2 = insert(:user)
      group = insert(:group, %{owner: user, users: [user, user2]})
      existing_pair = Pairmotron.TestHelper.create_pair([user, user2], group, 2017, 1)
      Pairmotron.TestHelper.create_pair([insert(:user)], group, 2017, 1)
      PairMaker.generate_pairs(2017, 1, group.id)
      [pair] = Repo.all(Pair)
      assert existing_pair.id == pair.id
    end
  end

  describe "generate_pairs/3 with group with multiple members" do
    setup do
      user = insert(:user)
      user2 = insert(:user)
      group = insert(:group, %{owner: user, users: [user, user2]})
      {:ok, [user: user, group: group, user2: user2]}
    end

    test "removes pairs for newly inactive members", %{group: group, user: user, user2: user2} do
      PairMaker.generate_pairs(2017, 1, group.id)
      user2 = Ecto.Changeset.change user2, active: false
      Repo.update user2
      PairMaker.generate_pairs(2017, 1, group.id)
      assert [%Pair{}] = Repo.all(Pair)
      [userpair] = Repo.all(UserPair)
      assert user.id == userpair.user_id
    end

    test "does not affect existing retro'd pairs", %{group: group, user: user, user2: user2} do
      pair = Pairmotron.TestHelper.create_pair([user, user2], group)
      create_retro(user, pair)
      user3 = insert(:user)
      Repo.insert %UserGroup{group_id: group.id, user_id: user3.id}
      PairMaker.generate_pairs(2017, 1, group.id)
      refute Repo.get_by(UserPair, %{user_id: user3.id, pair_id: pair.id})
    end

    test "can pair together many users" do
      user = insert(:user)
      group = insert(:group, %{owner: user, users: [user, insert(:user), insert(:user), insert(:user), insert(:user), insert(:user), insert(:user)]})
      PairMaker.generate_pairs(2017, 1, group.id)
    end

    test "can remove several no longer valid pairs" do
      user = insert(:user)
      user2 = insert(:user)
      user3 = insert(:user)
      user4 = insert(:user)
      group = insert(:group, %{owner: user, users: [user, user2, user3, user4]})
      PairMaker.generate_pairs(2017, 1, group.id)
      user |> Ecto.Changeset.change(active: false) |> Repo.update
      user2 |> Ecto.Changeset.change(active: false) |> Repo.update
      user3 |> Ecto.Changeset.change(active: false) |> Repo.update
      user4 |> Ecto.Changeset.change(active: false) |> Repo.update
      PairMaker.generate_pairs(2017, 1, group.id)
      assert Repo.all(UserPair) == []
    end
  end

  describe "fetch_or_gen/3" do
    setup do
      user = insert(:user)
      group = insert(:group, %{owner: user, users: [user]})
      {:ok, [user: user, group: group]}
    end

    test "fetches empty pairs when not current week", %{group: group} do
      assert {:error, [], "Not current week"} = PairMaker.fetch_or_gen(2000, 1, group.id)
      assert [] = Repo.all(Pair)
      assert [] = Repo.all(UserPair)
    end

    test "fetches pairs when current week and pairs already exist", %{group: group, user: user} do
      {year, week} = Timex.iso_week(Timex.today)
      assert [] = Repo.all(Pair)
      PairMaker.generate_pairs(year, week, group.id)
      {:ok, [%Pair{users: [fetched]}]} = PairMaker.fetch_or_gen(year, week, group.id)
      assert user.id == fetched.id
      assert [%Pair{}] = Repo.all(Pair)
      [userpair] = Repo.all(UserPair)
      assert user.id == userpair.user_id
    end

    test "generates pairs when current week", %{group: group, user: user} do
      {year, week} = Timex.iso_week(Timex.today)
      assert [] = Repo.all(Pair)
      {:ok, [%Pair{users: [fetched]}]} = PairMaker.fetch_or_gen(year, week, group.id)
      assert user.id == fetched.id
      assert [%Pair{}] = Repo.all(Pair)
      [userpair] = Repo.all(UserPair)
      assert user.id == userpair.user_id
    end
  end
end
