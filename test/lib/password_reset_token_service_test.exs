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

  describe "verify_token/1" do
    test "returns {:ok, token if a token exists and has not expired" do
      password_reset_token = insert(:password_reset_token)
      token_string = password_reset_token.token

      assert {:ok, valid_token} = PasswordResetTokenService.verify_token(token_string)
      assert valid_token.token == password_reset_token.token
    end

    test "returns {:error, :token_not_found} when there is no token with the given token string" do
      assert {:error, :token_not_found} = PasswordResetTokenService.verify_token("abc123")
    end

    test "returns {:error, :token_expired} when the token has expired" do
      long_ago = Ecto.DateTime.cast!({{2000, 1, 1}, {0, 0, 0}})
      password_reset_token = insert(:password_reset_token, %{inserted_at: long_ago})
      token_string = password_reset_token.token

      assert {:error, :token_expired} = PasswordResetTokenService.verify_token(token_string)
    end
  end
end
