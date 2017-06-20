defmodule Pairmotron.IntervalTest do
  use ExUnit.Case, async: true

  alias Pairmotron.Interval

  describe "new/1" do
    test "accepts an options hash" do
      interval = Interval.new(from: {2016, 2, 1}, until: {2016, 2, 2})
      assert interval.from == {2016, 2, 1}
      assert interval.until == {2016, 2, 2}
      assert interval.left_open == false
      assert interval.right_open == true
    end
  end

  describe "new/2" do
    test "creates a struct with sane defaults" do
      interval = Interval.new(nil, nil)
      assert interval
      assert interval.from == nil
      assert interval.until == nil
      assert interval.left_open == false
      assert interval.right_open == true
    end

    test "accepts four arguments" do
      interval = Interval.new({2016, 2, 1}, {2016, 2, 2}, true, false)
      assert interval.from == {2016, 2, 1}
      assert interval.until == {2016, 2, 2}
      assert interval.left_open == true
      assert interval.right_open == false
    end
  end
end
