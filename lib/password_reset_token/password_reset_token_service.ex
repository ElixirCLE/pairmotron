defmodule Pairmotron.PasswordResetTokenService do
  @moduledoc """
  PasswordResetTokenService is a utility class for dealing with generating and
  verifying password reset tokens.

  It consists of the generate_token/1 function which creates and returns a
  PasswordResetToken and verify_token/2, which verifies that a token exists
  with the given email.
  """

  alias Pairmotron.{PasswordResetToken, Repo, Types, User}

  @token_length 64

  @doc """
  Returns a password reset token for the user with the given email. When
  generate_token/1 returns an {:ok, token} tuple, that token will have also
  been inserted into the database. The PasswordResetToken's token field will be
  a random urlsafe base64 encoded string which can then be used in the password
  reset link to reset that users password.

  If there is no user with that email, generate_token/1 returns an error tuple
  of the form {:error, :no_user_with_email}.

  generate/token1 also handles retrying in the unlikely case that the randomly
  generated token is already associated with a PasswordResetToken.
  """
  @spec generate_token(String.t) :: {:ok, Types.password_reset_token} | {:error, atom()}
  def generate_token(email) when is_binary(email) do
    with {:ok, user} <- get_user_with_email(email),
      do: create_token(user)
  end
  def generate_token(_), do: {:error, :invalid_email}

  @spec get_user_with_email(String.t) :: Types.user | {:error, :no_user_with_email}
  defp get_user_with_email(email) do
    case Repo.get_by(User, %{email: email}) do
      nil -> {:error, :no_user_with_email}
      %User{} = user -> {:ok, user}
    end
  end

  @spec create_token(Types.user) :: Types.password_reset_token | {:error, :invalid_token}
  defp create_token(%User{} = user) do
    token = random_urlsafe_base64()
    changeset = PasswordResetToken.changeset(%PasswordResetToken{}, %{user_id: user.id, token: token})

    case Repo.insert(changeset) do
      {:ok, valid_token} -> {:ok, valid_token}
      {:error, %{errors: [token: {"has already been taken", _}]}} -> create_token(user)
      {:error, _} -> {:error, :invalid_token}
    end
  end

  @spec random_urlsafe_base64() :: String.t
  defp random_urlsafe_base64() do
    :crypto.strong_rand_bytes(@token_length)
    |> Base.url_encode64
    |> binary_part(0, @token_length)
  end

  @doc """
  verify_token/2 returns {:ok, token} if a token exists with the given
  token_string and a user containing the passed in email.

  verify_token/2 returns {:error, :token_not_found} if no token is found with
  the given token string or email
  """
  @spec verify_token(String.t, String.t) :: {:ok, Types.password_reset_token} | {:error, :token_not_found}
  def verify_token(email, token_string) do
    case email |> PasswordResetToken.token_by_email_and_token_string(token_string) |> Repo.one do
      nil -> {:error, :token_not_found}
      %PasswordResetToken{} = valid_token -> {:ok, valid_token}
    end
  end
end
