defmodule Pairmotron.TimeTest do
  use ExUnit.Case, async: true

  alias Pairmotron.Time

  describe "same_week?" do
    test "same week returns true" do
      assert Time.same_week?(2015, 53, ~D(2016-01-01))
    end

    test "different week returns false" do
      refute Time.same_week?(2014, 20, ~D(2016-01-01))
    end

    test "same year but different week returns false" do
      refute Time.same_week?(2016, 1, ~D(2016-01-30))
    end

    test "different year but same week returns false" do
      refute Time.same_week?(2016, 1, ~D(2015-01-01))
    end
  end
end
