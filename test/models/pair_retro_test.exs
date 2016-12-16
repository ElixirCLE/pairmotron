defmodule Pairmotron.PairRetroTest do
  use Pairmotron.ModelCase
  import Pairmotron.ControllerTestHelper, only: [create_pair: 3, create_retro: 2]
  alias Pairmotron.PairRetro

  @valid_attrs %{comment: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = PairRetro.changeset(%PairRetro{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = PairRetro.changeset(%PairRetro{}, @invalid_attrs)
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
end
