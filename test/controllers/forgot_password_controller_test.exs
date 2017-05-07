defmodule Pairmotron.ForgotPasswordControllerTest do
  use Pairmotron.ConnCase

  alias Pairmotron.PasswordResetToken

  describe "using the new action" do
    test "renders the form for sending a password reset token", %{conn: conn} do
      conn = get conn, forgot_password_path(conn, :new)
      assert html_response(conn, 200) =~ "Send Password Reset Email"
    end
  end

  describe "using the create action" do
    test "creates a PasswordResetToken if user with the given email exists", %{conn: conn} do
      user = insert(:user)
      conn = post conn, forgot_password_path(conn, :create), password_reset_token: %{email: user.email}
      assert Repo.get_by(PasswordResetToken, user_id: user.id)
      assert html_response(conn, 200) =~ "An email with password reset instructions has been sent"
    end

    test "does not create a PasswordResetToken if user does not exist with given email", %{conn: conn} do
      conn = post conn, forgot_password_path(conn, :create), password_reset_token: %{email: "null@email.com"}
      assert [] = Repo.all(PasswordResetToken)
      assert html_response(conn, 200) =~ "An email with password reset instructions has been sent"
    end
  end
end
