defmodule Pairmotron.PasswordResetTokenTest do
  use Pairmotron.ModelCase

  alias Pairmotron.PasswordResetToken

  @valid_attrs %{token: "abc12345", user_id: 123}

  describe "changeset/2" do
    test "with all required attributes is valid" do
      changeset = PasswordResetToken.changeset(%PasswordResetToken{}, @valid_attrs)
      assert changeset.valid?
    end

    test "with only user_id is invalid" do
      changeset = PasswordResetToken.changeset(%PasswordResetToken{}, %{user_id: 123})
      refute changeset.valid?
    end

    test "with only token is invalid" do
      changeset = PasswordResetToken.changeset(%PasswordResetToken{}, %{token: "abc12345"})
      refute changeset.valid?
    end

    test "with no attributes is invalid" do
      changeset = PasswordResetToken.changeset(%PasswordResetToken{}, %{})
      refute changeset.valid?
    end
  end

end
