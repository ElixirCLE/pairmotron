defmodule Pairmotron.MixerTest do
  use ExUnit.Case, async: true

  alias Pairmotron.Mixer

  describe ".mixify" do
    test "empty list returns an empty list" do
      assert Mixer.mixify([]) == []
    end

    test "list of one returns same list" do
      assert Mixer.mixify([1]) == [1]
    end

    test "list of two things with the same seed returns a predictable list" do
      assert Mixer.mixify([1, 2]) == [2, 1]
    end

    test "list of many things with the same seed returns a predictable list" do
      assert Mixer.mixify([1, 2, 3, 4, 5, 6, 7, 8], 3) == [4, 5, 6, 7, 8, 1, 3, 2]
    end
  end
end
