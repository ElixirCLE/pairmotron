defmodule Pairmotron.EmailTest do
  use ExUnit.Case, async: true

  alias Pairmotron.Email
  import Pairmotron.Router.Helpers
  import Pairmotron.Factory

  describe "password_reset_email/1" do
    setup do
      token = build(:password_reset_token)
      {:ok, [token: token]}
    end

    test "returns an email to the user associated with the token", %{token: token} do
      assert Email.password_reset_email(token).to == token.user.email
    end

    test "returns an email from no-reply@pairmotron.com", %{token: token} do
      assert Email.password_reset_email(token).from == "no-reply@pairmotron.com"
    end

    test "returns an email with a subject of 'Pairmotron Password Reset'", %{token: token} do
      assert Email.password_reset_email(token).subject == "Pairmotron Password Reset"
    end

    test "returns an email with a link reset password in html_body", %{token: token} do
      assert Email.password_reset_email(token).html_body =~
        password_reset_url(Pairmotron.Endpoint, :edit, token.token)
    end

    test "returns an email with a link reset password in text_body", %{token: token} do
      assert Email.password_reset_email(token).text_body =~
        password_reset_url(Pairmotron.Endpoint, :edit, token.token)
    end
  end
end
