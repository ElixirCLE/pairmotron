defmodule Pairmotron.ForgotPasswordController do
  @moduledoc """
  Handles users requesting a password reset email. Renders a form for entering
  which email to send a password reset token to, as well as generating that
  token and sending it.
  """
  use Pairmotron.Web, :controller

  alias Pairmotron.{PasswordResetToken, PasswordResetTokenService}

  @spec new(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def new(conn, _params) do
    changeset = PasswordResetToken.changeset(%PasswordResetToken{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"password_reset_token" => %{"email" => email}}) do
    PasswordResetTokenService.generate_token(email)
    render(conn, "email_sent.html")
  end
end
