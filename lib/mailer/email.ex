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
    Someone requested a password change for your Pairmotron account. If this was requested by you, please set a new password here:
    <br><br>
    <a href=#{reset_path(token_string)}>Click here to reset your password</a>
    """
  end

  @spec password_reset_email_text_body(String.t) :: String.t
  defp password_reset_email_text_body(token_string) do
    """
    Someone requested a password change for your Pairmotron account. If this was requested by you, please set a new password here:
    \n\n
    Follow this link to reset your password: #{reset_path(token_string)}
    """
  end

  @spec reset_path(String.t) :: String.t
  defp reset_path(token_string) do
    password_reset_url(Pairmotron.Endpoint, :edit, token_string)
  end

  @doc """
  Returns an email ready to be sent by Bamboo to a user instructing them that
  they have been invited to a group. It contains a link to their invitations
  page.
  """
  @spec group_invitation_email(Types.user, Types.group) :: Bamboo.Email.t
  def group_invitation_email(user, group) do
    new_email()
    |> to(user.email)
    |> from("no-reply@pairmotron.com")
    |> subject("Pairmotron Group Invitation")
    |> html_body(group_invitation_email_html_body(group.name))
    |> text_body(group_invitation_email_text_body(group.name))
  end

  @spec group_invitation_email_html_body(String.t) :: String.t
  defp group_invitation_email_html_body(group_name) do
    """
    You have been invited to join the #{group_name} group in Pairmotron!
    <br><br>
    <a href=#{invitation_index_path()}>Click here to view your invitations</a>
    <br><br>
    #{unsubscribe_html()}
    """
  end

  @spec group_invitation_email_text_body(String.t) :: String.t
  defp group_invitation_email_text_body(group_name) do
    """
    You have been invited to join the #{group_name} group in Pairmotron!
    \n\n
    Follow this link to view your invitations: #{invitation_index_path()}
    \n\n
    #{unsubscribe_text()}
    """
  end

  @spec invitation_index_path() :: String.t
  defp invitation_index_path() do
    users_group_membership_request_url(Pairmotron.Endpoint, :index)
  end

  @spec unsubscribe_html() :: String.t
  defp unsubscribe_html() do
    """
    If you would not like to receive further emails from pairmotron, follow 
    <a href=#{user_profile_edit_path()}>this link</a> to disable emailing from 
    your profile.
    """
  end

  @spec unsubscribe_text() :: String.t
  defp unsubscribe_text() do
    """
    If you would not like to receive further emails from pairmotron, follow this 
    link: #{user_profile_edit_path()} to disable emailing from your profile.
    """
  end

  @spec user_profile_edit_path() :: String.t
  defp user_profile_edit_path() do
    profile_url(Pairmotron.Endpoint, :edit)
  end
end
