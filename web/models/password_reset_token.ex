defmodule Pairmotron.PasswordResetToken do
  use Pairmotron.Web, :model

  schema "password_reset_tokens" do
    belongs_to :user, Pairmotron.User
    field :token, :string

    timestamps()
  end

  @all_fields ~w(user_id token)
  @required_fields [:user_id, :token]

  @doc """
  Builds a changeset for a password reset token.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:token)
  end

  def token_by_email_and_token_string(email, token) do
    from password_reset_token in Pairmotron.PasswordResetToken,
    join: user in assoc(password_reset_token, :user),
    where: user.email == ^email,
    where: password_reset_token.token == ^token
  end
end
