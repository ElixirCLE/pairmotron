defmodule Pairmotron.PairRetroTest do
  use Pairmotron.ModelCase

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
end
