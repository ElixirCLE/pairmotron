defmodule Pairmotron.GravatarTest do
  use ExUnit.Case, async: true

  alias Pairmotron.Gravatar

  describe "Gavatar" do
    test "takes an email and returns a gravatar avatar url" do
      assert Gravatar.url("eric@example.com") =~ "gravatar.com/avatar/"
    end
  end
end
