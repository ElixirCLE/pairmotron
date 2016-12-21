defmodule Pairmotron.CalendarTest do
  use ExUnit.Case, async: true

  alias Pairmotron.Calendar

  describe "same_week?" do
    test "same week returns true" do
      assert Calendar.same_week?(2015, 53, ~D(2016-01-01))
    end

    test "different week returns false" do
      refute Calendar.same_week?(2014, 20, ~D(2016-01-01))
    end

    test "same year but different week returns false" do
      refute Calendar.same_week?(2016, 1, ~D(2016-01-30))
    end

    test "different year but same week returns false" do
      refute Calendar.same_week?(2016, 1, ~D(2015-01-01))
    end
  end

  describe "past_week?" do
    test "same week returns false" do
      refute Calendar.past_week?(2015, 53, ~D(2016-01-01))
    end

    test "future week returns false" do
      refute Calendar.past_week?(2016, 10, ~D(2016-01-01))
    end

    test "past week in same year returns true" do
      assert Calendar.past_week?(2016, 1, ~D(2016-10-01))
    end

    test "past week in past year returns true" do
      assert Calendar.past_week?(2015, 50, ~D(2016-02-01))
    end
  end
end
