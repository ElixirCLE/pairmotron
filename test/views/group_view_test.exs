defmodule Pairmotron.GroupViewTest do
  use Pairmotron.ConnCase, async: true
  alias Pairmotron.GroupView

  test "truncate/2 does nothing to a string shorted than the length" do
    assert GroupView.truncate("short string", 20) == "short string"
  end
  test "truncate/2 shortens and adds ellipses to long strings" do
    assert GroupView.truncate("long string", 6) == "long s..."
  end
  test "truncate/2 ignores nil" do
    assert GroupView.truncate(nil, 5) == nil
  end
end

