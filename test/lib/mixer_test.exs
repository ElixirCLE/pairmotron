defmodule Pairmotron.MixerTest do
  use ExUnit.Case, async: true

  alias Pairmotron.Mixer

  describe "mixify/1 with an empty list" do
    test "returns an empty list" do
      assert Mixer.mixify([]) == []
    end
  end

  describe "mixify/1 with a list of one" do
    test "returns the same list" do
      assert Mixer.mixify([1]) == [1]
    end
  end

  describe "mixify/1 with a list of two" do
    test "returns a list containing both things" do
      results = Mixer.mixify([1, 2])
      assert Enum.sort(results) == [1, 2]
    end
  end

  describe "mixify/1 with a list of many" do
    test "returns a list containing all things" do
      results = Mixer.mixify([1, 2, 3, 4, 5, 6, 7, 8])
      assert Enum.sort(results) == [1, 2, 3, 4, 5, 6, 7, 8]
    end

    test "returns a list not in the same order" do
      results = Mixer.mixify([1, 2, 3, 4, 5, 6, 7, 8])
      refute results == [1, 2, 3, 4, 5, 6, 7, 8]
    end
  end

  describe "mixify/2 with a custom shuffle function" do
    test "applies the function" do
      results = Mixer.mixify([1, 2, 3, 4, 5], &Enum.reverse/1)
      assert results == [5, 4, 3, 2, 1]
    end
  end
end
