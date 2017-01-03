defmodule Pairmotron.PairRetroTest do
  use Pairmotron.ModelCase
  import Pairmotron.TestHelper, only: [create_pair: 1, create_pair: 3, create_retro: 2]
  alias Pairmotron.PairRetro

  @valid_attrs %{subject: "subject", reflection: "reflection", pair_date: Timex.today}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    user = insert(:user)
    pair = create_pair([user])
    attrs = Map.merge(@valid_attrs, %{user_id: user.id,
                                      pair_id: pair.id})
    changeset = PairRetro.changeset(%PairRetro{}, attrs, Timex.today)
    assert changeset.valid?
  end

  test "changeset with a pair that occurred after the pair_date is invalid" do
    user = insert(:user)
    pair = create_pair([user], 2016, 1)
    attrs = Map.merge(@valid_attrs, %{pair_date: ~D(2011-01-01),
                                      user_id: user.id,
                                      pair_id: pair.id})
    changeset = PairRetro.changeset(%PairRetro{}, attrs, ~D(2016-01-04))
    refute changeset.valid?
  end

  test "changeset with a pair_date in the future is invalid" do
    user = insert(:user)
    pair = create_pair([user])
    attrs = Map.merge(@valid_attrs, %{pair_date: Timex.shift(Timex.today, days: 1),
                                      user_id: user.id,
                                      pair_id: pair.id})
    changeset = PairRetro.changeset(%PairRetro{}, attrs, nil)
    refute changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = PairRetro.changeset(%PairRetro{}, @invalid_attrs, nil)
    refute changeset.valid?
  end

  describe ".retro_for_user_and_week" do
    test "returns the retro for the user for the pair for the given week" do
      user = insert(:user)
      pair = create_pair([user], 2016, 25)
      retro = create_retro(user, pair)
      returned_retro = Repo.one(PairRetro.retro_for_user_and_week(user, 2016, 25))
      assert returned_retro.id == retro.id
    end

    test "returns nil when there has been a retro for the user but on the wrong week" do
      user = insert(:user)
      pair = create_pair([user], 2016, 25)
      create_retro(user, pair)
      refute Repo.one(PairRetro.retro_for_user_and_week(user, 1999, 10))
    end

    test "returns nil when there has been no retro for the user for the given week" do
      user = insert(:user)
      create_pair([user], 2016, 25)
      refute Repo.one(PairRetro.retro_for_user_and_week(user, 2016, 25))
    end

    test "returns nil when there has been no pair for the user for the given week" do
      user = insert(:user)
      create_pair([user], 2016, 25)
      refute Repo.one(PairRetro.retro_for_user_and_week(user, 1999, 10))
    end

    test "returns nil when there has been no pair for the user ever" do
      user = insert(:user)
      refute Repo.one(PairRetro.retro_for_user_and_week(user, 2016, 25))
    end
  end

  describe ".users_retros" do
    test "returns nil when there are no retros" do
      user = insert(:user)
      refute Repo.one(PairRetro.users_retros(user))
    end

    test "returns the retro that is assigned to the passed in user" do
      user = insert(:user)
      pair = create_pair([user])
      retro = create_retro(user, pair)
      returned_retro = Repo.one(PairRetro.users_retros(user))
      assert returned_retro.id == retro.id
    end

    test "does not return a retro for a different user" do
      [retro_user, other_user] = insert_pair(:user)
      pair = create_pair([retro_user])
      create_retro(retro_user, pair)
      refute Repo.one(PairRetro.users_retros(other_user))
    end
  end
end
