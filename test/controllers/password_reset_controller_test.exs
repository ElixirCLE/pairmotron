defmodule Pairmotron.PasswordResetControllerTest do
  use Pairmotron.ConnCase

  alias Pairmotron.PasswordResetToken

  describe "using the new action" do
    test "renders the form for sending a password reset token", %{conn: conn} do
      conn = get conn, password_reset_path(conn, :new)
      assert html_response(conn, 200) =~ "Send Password Reset Email"
    end
  end

  describe "using the create action" do
    test "creates a PasswordResetToken if user with the given email exists", %{conn: conn} do
      user = insert(:user)
      conn = post conn, password_reset_path(conn, :create), password_reset_token: %{email: user.email}
      assert Repo.get_by(PasswordResetToken, user_id: user.id)
      assert html_response(conn, 200) =~ "An email with password reset instructions has been sent"
    end

    test "does not create a PasswordResetToken if user does not exist with given email", %{conn: conn} do
      conn = post conn, password_reset_path(conn, :create), password_reset_token: %{email: "null@email.com"}
      assert [] = Repo.all(PasswordResetToken)
      assert html_response(conn, 200) =~ "An email with password reset instructions has been sent"
    end
  end

  describe "using the edit action" do
    test "renders the form to reset password when given a valid token", %{conn: conn} do
      password_reset_token = insert(:password_reset_token)
      conn = get conn, password_reset_path(conn, :edit, password_reset_token.token)
      assert html_response(conn, 200) =~ "Enter new password"
    end

    test "renders an error and redirects to login if token is not found", %{conn: conn} do
      conn = get conn, password_reset_path(conn, :edit, "nonexistent_token")
      assert redirected_to(conn) == session_path(conn, :new)
      assert get_flash(conn, :error) == "Sorry, that is not a valid password reset token"
    end
  end
end
