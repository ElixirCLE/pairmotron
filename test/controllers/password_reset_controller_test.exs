defmodule Pairmotron.PasswordResetControllerTest do
  use Pairmotron.ConnCase
  use Bamboo.Test

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

    test "sends a password reset email if user with the given email exists", %{conn: conn} do
      user = insert(:user)
      post conn, password_reset_path(conn, :create), password_reset_token: %{email: user.email}
      token = Repo.get_by(PasswordResetToken, user_id: user.id) |> Repo.preload(:user)
      assert_delivered_email Pairmotron.Email.password_reset_email(token)
    end

    test "does not create a PasswordResetToken if user does not exist with given email", %{conn: conn} do
      conn = post conn, password_reset_path(conn, :create), password_reset_token: %{email: "null@email.com"}
      assert [] = Repo.all(PasswordResetToken)
      assert html_response(conn, 200) =~ "An email with password reset instructions has been sent"
    end

    test "does not send an email if user does not exist with the given email", %{conn: conn} do
      post conn, password_reset_path(conn, :create), password_reset_token: %{email: "null@email.com"}
      assert_no_emails_delivered()
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

    test "renders an error and redirects to login if the token has expired", %{conn: conn} do
      long_ago = Ecto.DateTime.cast!({{2000, 1, 1}, {0, 0, 0}})
      password_reset_token = insert(:password_reset_token, %{inserted_at: long_ago})

      conn = get conn, password_reset_path(conn, :edit, password_reset_token.token)
      assert redirected_to(conn) == session_path(conn, :new)
      assert get_flash(conn, :error) == "Sorry, that password reset token has expired."
    end
  end

  describe "using the update action" do
    test "resets the user password, deletes token, and logs in user when the token is valid", %{conn: conn} do
      user = insert(:user)
      password_reset_token = insert(:password_reset_token, %{user: user})

      attrs = %{password: "password", password_confirmation: "password"}
      conn = put conn, password_reset_path(conn, :update, password_reset_token.token), user: attrs

      assert redirected_to(conn) == pair_path(conn, :index)
      refute Repo.get(PasswordResetToken, password_reset_token.id)
      updated_user = Repo.get(Pairmotron.User, user.id)
      refute user.password_hash == updated_user.password_hash
      assert Guardian.Plug.current_resource(conn)
    end

    test "errors when the token does not exist", %{conn: conn} do
      attrs = %{password: "password", password_confirmation: "password"}
      conn = put conn, password_reset_path(conn, :update, "nonexistent_token"), user: attrs

      assert redirected_to(conn) == session_path(conn, :new)
      assert get_flash(conn, :error) == "Sorry, that is not a valid password reset token"
    end

    test "errors when the token has expired", %{conn: conn} do
      user = insert(:user)
      long_ago = Ecto.DateTime.cast!({{2000, 1, 1}, {0, 0, 0}})
      password_reset_token = insert(:password_reset_token, %{inserted_at: long_ago, user: user})

      attrs = %{password: "password", password_confirmation: "password"}
      conn = put conn, password_reset_path(conn, :update, password_reset_token.token), user: attrs

      assert redirected_to(conn) == session_path(conn, :new)
      assert get_flash(conn, :error) == "Sorry, that is not a valid password reset token"
      assert Repo.get(PasswordResetToken, password_reset_token.id)
      hopefully_not_updated_user = Repo.get(Pairmotron.User, user.id)
      assert user.password_hash == hopefully_not_updated_user.password_hash
    end

    test "errors and rerenders reset form if the password and the password confirmation do not match", %{conn: conn} do
      user = insert(:user)
      password_reset_token = insert(:password_reset_token, %{user: user})

      attrs = %{password: "password", password_confirmation: "different_password"}
      conn = put conn, password_reset_path(conn, :update, password_reset_token.token), user: attrs

      assert html_response(conn, 200) =~ "Enter new password"
      assert Repo.get(PasswordResetToken, password_reset_token.id)
      hopefully_not_updated_user = Repo.get(Pairmotron.User, user.id)
      assert user.password_hash == hopefully_not_updated_user.password_hash
    end
  end
end
