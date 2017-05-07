defmodule Pairmotron.PasswordResetTokenServiceTest do
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

  describe "verify_token/2" do
    test "returns {:ok, token} if a token exists" do
      password_reset_token = insert(:password_reset_token)
      email = password_reset_token.user.email
      token = password_reset_token.token

      assert {:ok, valid_token} = PasswordResetTokenService.verify_token(email, token)
      assert valid_token.user_id == password_reset_token.user.id
      assert valid_token.token == password_reset_token.token
    end

    test "returns {:error, :token_not_found} when there is no user with the given email" do
      password_reset_token = insert(:password_reset_token)
      token = password_reset_token.token

      assert {:error, :token_not_found} = PasswordResetTokenService.verify_token("bad_email", token)
    end

    test "returns {:error, :token_not_found} when there is no token with the given token string" do
      password_reset_token = insert(:password_reset_token)
      email = password_reset_token.user.email

      assert {:error, :token_not_found} = PasswordResetTokenService.verify_token(email, "abc123")
    end

    test "returns {:error, :token_not_found} when there is no token or email" do
      assert {:error, :token_not_found} = PasswordResetTokenService.verify_token("bad_email", "abc123")
    end
  end
end
