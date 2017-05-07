defmodule Pairmotron.PasswordResetTokenServiceTest do
  #use ExUnit.Case, async: true

  use Pairmotron.ModelCase

  import Pairmotron.Factory

  alias Pairmotron.PasswordResetTokenService

  describe "generate_token\1" do
    test "returns :ok and creates a token when given an email associated with a user" do
      user = insert(:user)
      assert {:ok, token} = PasswordResetTokenService.generate_token(user.email)
      assert token.user_id == user.id
    end

    test "returns an error tuple when given an email not associated with any user" do
      assert {:error, :no_user_with_email} == PasswordResetTokenService.generate_token("nonexistent@email.com") 
    end

    test "returns an error tuple when given am invalid email type" do
      assert {:error, :invalid_email} == PasswordResetTokenService.generate_token([123])
    end
  end
end
