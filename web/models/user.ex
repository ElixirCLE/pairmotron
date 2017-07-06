defmodule Pairmotron.User do
  @moduledoc """
  Is a user which can log in to the application and also be paired up in a
  Pair.

  Users can also create and own Groups and create PairRetros.

  Users can be active which means that they are actively paired by the pairing
  logic.

  Users can also be admins, which gives them access to the /admin routes as
  well as some features such as repairifying in the standard routes.
  """
  use Pairmotron.Web, :model

  schema "users" do
    field :name, :string
    field :email, :string
    field :active, :boolean
    field :is_admin, :boolean
    field :email_disabled, :boolean

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string

    has_many :pair_retros, Pairmotron.PairRetro
    many_to_many :groups, Pairmotron.Group, join_through: Pairmotron.UserGroup
    has_many :group_membership_requests, Pairmotron.GroupMembershipRequest

    timestamps()
  end

  @minimum_password_length 8

  @all_params ~w(name email password password_confirmation active is_admin)
  @required_params [:name, :email]

  @doc """
  Builds a changeset based on the `struct` and `params`.

  Meant to only be used by administrators through an administrator interface as
  this changeset allows all properties to be changed including the is_admin
  field.
  """
  @spec changeset(map() | %Ecto.Changeset{}, map()) :: %Ecto.Changeset{}
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_params)
    |> validate_required(@required_params)
    |> common_changeset
  end

  @all_registration_params ~w(name email password password_confirmation active)
  @required_registration_params [:name, :email, :password, :password_confirmation]

  @doc """
  Builds a changeset based on the `struct` and `params`.

  Used by the RegistrationController. Requires a password and
  password_confirmation to be specified and does not allow the is_admin field
  to be altered.
  """
  @spec registration_changeset(map() | %Ecto.Changeset{}, map()) :: %Ecto.Changeset{}
  def registration_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_registration_params)
    |> validate_required(@required_registration_params)
    |> common_changeset
  end

  @all_profile_params ~w(name email active password password_confirmation)
  @required_profile_params [:name, :email]

  @doc """
  Builds a changeset based on the `struct` and `params`.

  Used by the ProfileController. Does not require a password so that users can
  modify their other attributes without being forced to change their password.
  However, users can update their password using this changeset if they wish.
  Does not allow the modification of the is_admin field.
  """
  @spec profile_changeset(map() | %Ecto.Changeset{}, map()) :: %Ecto.Changeset{}
  def profile_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_profile_params)
    |> validate_required(@required_profile_params)
    |> common_changeset
  end

  @password_reset_params [:password, :password_confirmation]

  @doc """
  Changeset for use in the PasswordResetController when a user is submitting a
  new password. Only allows the password to be changed, and also required it to
  be changed.
  """
  @spec password_reset_changeset(map() | %Ecto.Changeset{}, map()) :: %Ecto.Changeset{}
  def password_reset_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @password_reset_params)
    |> validate_required(@password_reset_params)
    |> common_changeset
  end

  @spec common_changeset(%Ecto.Changeset{}) :: %Ecto.Changeset{}
  defp common_changeset(changeset) do
    changeset
    |> Sanitizer.sanitize([:name, :email])
    |> unique_constraint(:email)
    |> validate_length(:password, min: @minimum_password_length)
    |> validate_length(:password_confirmation, min: @minimum_password_length)
    |> validate_confirmation(:password)
    |> hash_password_if_changed_and_valid
  end

  # Hashes the contents of the :password field and inserts the results into the
  # :password_hash field. Only hashes and inserts if the password was changed
  # and the changeset is valid.
  @spec hash_password_if_changed_and_valid(%Ecto.Changeset{}) :: %Ecto.Changeset{}
  defp hash_password_if_changed_and_valid(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end

  @spec active_users() :: %Ecto.Query{}
  def active_users do
    Pairmotron.User
    |> Ecto.Query.where([u], u.active)
  end

  @spec users_not_in_group(Types.group | integer() | binary()) :: %Ecto.Query{}
  def users_not_in_group(group = %Pairmotron.Group{}), do: users_not_in_group(group.id)
  def users_not_in_group(group_id) do
    from user in Pairmotron.User,
    left_join: user_group in Pairmotron.UserGroup, on: user_group.user_id == user.id and user_group.group_id == ^group_id,
    where: is_nil(user_group.user_id),
    order_by: user.name
  end
end
