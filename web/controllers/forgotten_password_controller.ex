defmodule Pairmotron.ForgottenPasswordController do
  @moduledoc """
  Handles users requesting a password reset email. Renders a form for entering
  which email to send a password reset token to, as well as generating that
  token and sending it.
  """
  use Pairmotron.Web, :controller

  alias Pairmotron.PasswordResetToken

  @spec new(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def new(conn, _params) do
    changeset = PasswordResetToken.changeset(%PasswordResetToken{}, %{})
    render(conn, "new.html", changeset: changeset)
  end
end
