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
  @token_hour_lifetime 24

  @doc """
  Returns a password reset token for the user with the given email. When
  generate_token/1 returns an {:ok, token} tuple, that token will have also
  been inserted into the database. The PasswordResetToken's token field will be
  a random urlsafe base64 encoded string which can then be used in the password
  reset link to reset that users password.

  If there is no user with that email, generate_token/1 returns an error tuple
  of the form {:error, :no_user_with_email}.
  """
  @spec generate_token(String.t) :: {:ok, Types.password_reset_token} | {:error, atom()}
  def generate_token(email) when is_binary(email) do
    with {:ok, user} <- get_user_with_email(email),
         {:ok, token} <- create_token(user),
      do: {:ok, token}
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
      {:ok, valid_token} -> {:ok, Repo.preload(valid_token, :user)}
      {:error, _} -> {:error, :invalid_token}
    end
  end

  @spec random_urlsafe_base64() :: String.t
  defp random_urlsafe_base64() do
    @token_length
    |> :crypto.strong_rand_bytes
    |> Base.url_encode64
    |> binary_part(0, @token_length)
  end

  @doc """
  verify_token/1 returns {:ok, token} if a token exists with the given
  token_string that has not expired.

  verify_token/1 returns {:error, :invalid_token} if no token with that
  token_string is currently in the database, and {:error, :token_expired} if a
  token does exist but it has expired.

  Token are valid for 24 hours after they are created, and then they can no
  longer be used to reset passwords.
  """
  @spec verify_token(String.t) :: {:ok, Types.password_reset_token} | {:error, :token_not_found | :token_expired}
  def verify_token(token_string) do
    case token_string |> PasswordResetToken.token_by_token_string |> Repo.one do
      nil -> {:error, :token_not_found}
      %PasswordResetToken{} = valid_token ->
        if token_has_expired(valid_token) do
          {:error, :token_expired}
        else
          {:ok, valid_token}
        end
    end
  end

  @spec token_has_expired(Types.password_reset_token) :: boolean()
  defp token_has_expired(password_reset_token) do
    Timex.diff(NaiveDateTime.utc_now, password_reset_token.inserted_at, :hours) > @token_hour_lifetime
  end
end
