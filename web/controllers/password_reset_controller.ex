defmodule Pairmotron.PasswordResetController do
  @moduledoc """
  Handles users requesting a password reset email. Renders a form for entering
  which email to send a password reset token to, as well as generating that
  token and sending it.
  """
  use Pairmotron.Web, :controller

  alias Pairmotron.{PasswordResetToken, PasswordResetTokenService, User}

  @spec new(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def new(conn, _params) do
    changeset = PasswordResetToken.changeset(%PasswordResetToken{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  @spec create(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def create(conn, %{"password_reset_token" => %{"email" => email}}) do
    PasswordResetTokenService.generate_token(email)
    render(conn, "email_sent.html")
  end

  @spec edit(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def edit(conn, %{"token_string" => token_string}) do
    case token_string |> PasswordResetToken.token_by_token_string |> Repo.one do
      nil ->
        conn
        |> put_flash(:error, "Sorry, that is not a valid password reset token")
        |> redirect(to: session_path(conn, :new))
      %PasswordResetToken{} ->
        changeset = User.password_reset_changeset(%User{})
        render(conn, "reset.html", changeset: changeset, token_string: token_string)
    end
  end

  @spec update(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def update(conn, params) do
    IO.inspect params
    conn
  end
end
