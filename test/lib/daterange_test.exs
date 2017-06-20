defmodule Pairmotron.DaterangeTest do
  use ExUnit.Case, async: true

  alias Pairmotron.{Daterange, Interval}

  describe "cast/1" do
    test "supports Intervals" do
      interval = Interval.new(from: {2016, 2, 1}, until: {2016, 2, 2})
      assert Daterange.cast(interval) == {:ok, interval}
    end

    test "supports lower upper erlang date lists" do
      interval = Interval.new(from: {2016, 2, 1}, until: {2016, 2, 2})
      assert Daterange.cast([{2016, 2, 1}, {2016, 2, 2}]) == {:ok, interval}
    end

    test "supports lower upper Date lists" do
      interval = Interval.new(from: {2016, 2, 1}, until: {2016, 2, 2})
      assert Daterange.cast([~D(2016-02-01), ~D(2016-02-02)]) == {:ok, interval}
    end

    test "returns error on anything else" do
      assert Daterange.cast("foo") == :error
      assert Daterange.cast(~D(2016-02-01)) == :error
      assert Daterange.cast({1, 1}) == :error
    end
  end

  describe "dump/1" do
    test "returns a Postgrex.Range" do
      interval = Interval.new(from: ~D(2016-02-01),
                              until: ~D(2016-02-07),
                              left_open: true)
      range = %Postgrex.Range{lower: {2016, 2, 1},
                              upper: {2016, 2, 7},
                              lower_inclusive: false,
                              upper_inclusive: false}
      assert Daterange.dump(interval) == {:ok, range}
    end

    test "returns error on anything else" do
      assert Daterange.dump("foo") == :error
      assert Daterange.dump(~D(2016-02-01)) == :error
      assert Daterange.dump({1, 1}) == :error
      assert Daterange.dump([~D(2016-02-01), ~D(2016-02-02)]) == :error
    end
  end

  describe "load/1" do
    test "returns an Interval" do
      interval = Interval.new(from: ~D(2016-02-01),
                              until: ~D(2016-02-07),
                              left_open: true)
      range = %Postgrex.Range{lower: ~D(2016-02-01),
                              upper: ~D(2016-02-07),
                              lower_inclusive: false,
                              upper_inclusive: false}
      assert Daterange.load(range) == {:ok, interval}
    end
  end
end
