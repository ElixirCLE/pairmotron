defmodule Pairmotron.ForgottenPasswordControllerTest do
  use Pairmotron.ConnCase

  alias Pairmotron.PasswordResetToken

  describe "using the new action" do
    test "renders the form for sending a password reset token", %{conn: conn} do
      conn = get conn, forgotten_password_path(conn, :new)
      assert html_response(conn, 200) =~ "Send Password Reset Email"
    end
  end

end
