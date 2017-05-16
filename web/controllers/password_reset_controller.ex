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
    case PasswordResetTokenService.verify_token(token_string) do
      {:ok, _valid_token} ->
        changeset = User.password_reset_changeset(%User{})
        render(conn, "reset.html", changeset: changeset, token_string: token_string)
      {:error, :token_not_found} ->
        conn
        |> put_flash(:error, "Sorry, that is not a valid password reset token")
        |> redirect(to: session_path(conn, :new))
      {:error, :token_expired} ->
        conn
        |> put_flash(:error, "Sorry, that password reset token has expired.")
        |> redirect(to: session_path(conn, :new))
    end
  end

  @spec update(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def update(conn, %{"token_string" => token_string, "user" => user_params}) do
    case PasswordResetTokenService.verify_token(token_string) do
      {:ok, valid_token} ->
        changeset = User.password_reset_changeset(valid_token.user, user_params)
        case Repo.update(changeset) do
          {:ok, project} ->
            Repo.delete!(valid_token)
            conn
            |> put_flash(:info, "Password successfully reset")
            |> redirect(to: pair_path(conn, :index))
          {:error, changeset} ->
            render(conn, "reset.html", changeset: changeset, token_string: token_string)
        end
      {:error, :token_not_found} ->
        conn
        |> put_flash(:error, "Sorry, that is not a valid password reset token")
        |> redirect(to: session_path(conn, :new))
      {:error, :token_expired} ->
        conn
        |> put_flash(:error, "Sorry, that password reset token has expired.")
        |> redirect(to: session_path(conn, :new))
    end
  end
end
