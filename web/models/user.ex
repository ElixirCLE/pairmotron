defmodule Pairmotron.User do
  use Pairmotron.Web, :model

  schema "users" do
    field :name, :string
    field :email, :string
    field :active, :boolean
    field :is_admin, :boolean

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string

    has_many :pair_retros, Pairmotron.PairRetro
    many_to_many :groups, Pairmotron.Group, join_through: "users_groups"

    timestamps()
  end

  @minimum_password_length 8

  @required_params ~w(name email)
  @optional_params ~w(password password_confirmation active)

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_params, @optional_params)
    |> common_changeset
  end

  @required_registration_params ~w(name email password password_confirmation)
  @optional_registration_params ~w(active)

  def registration_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_registration_params, @optional_registration_params)
    |> common_changeset
  end

  defp common_changeset(changeset) do
    changeset
    |> unique_constraint(:email)
    |> validate_length(:password, min: @minimum_password_length)
    |> validate_length(:password_confirmation, min: @minimum_password_length)
    |> validate_confirmation(:password)
    |> generate_password
  end

  defp generate_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end

  def active_users do
    Pairmotron.User
    |> Ecto.Query.where([u], u.active)
  end
end
