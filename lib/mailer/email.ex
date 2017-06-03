defmodule Pairmotron.Email do
  @moduledoc """
  The Pairmotron.Email module contains functions for generating standard emails
  to be sent using Bamboo.
  """
  import Bamboo.Email

  alias Pairmotron.Types
  import Pairmotron.Router.Helpers

  @doc """
  Returns an email ready to be sent by Bamboo to the user associated with the
  given password_reset_token. The email contains a link to the
  PasswordResetController's :edit form where the user can set a new password.

  The password_reset_token's :user relation must be preloaded.
  """
  @spec password_reset_email(Types.password_reset_token) :: Bamboo.Email.t
  def password_reset_email(password_reset_token)  do
    new_email()
    |> to(password_reset_token.user.email)
    |> from("no-reply@pairmotron.com")
    |> subject("Pairmotron Password Reset")
    |> html_body(password_reset_email_html_body(password_reset_token.token))
    |> text_body(password_reset_email_text_body(password_reset_token.token))
  end

  @spec password_reset_email_html_body(String.t) :: String.t
  defp password_reset_email_html_body(token_string) do
    """
    It looks like you've requested a password reset.<br><br>
    <a href=#{reset_path(token_string)}>Click here to reset your password</a>
    """
  end

  @spec password_reset_email_text_body(String.t) :: String.t
  defp password_reset_email_text_body(token_string) do
    """
    It looks like you've requested a passwrod reset.\n\n
    Follow this link to reset your password: #{reset_path(token_string)}
    """
  end

  @spec reset_path(String.t) :: String.t
  defp reset_path(token_string) do
    password_reset_url(Pairmotron.Endpoint, :edit, token_string)
  end
end
