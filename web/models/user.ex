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

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string

    has_many :pair_retros, Pairmotron.PairRetro
    many_to_many :groups, Pairmotron.Group, join_through: "users_groups"
    has_many :group_membership_requests, Pairmotron.GroupMembershipRequest

    timestamps()
  end

  @minimum_password_length 8

  @required_params ~w(name email)
  @optional_params ~w(password password_confirmation active is_admin)

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @spec changeset(map() | %Ecto.Changeset{}, map()) :: %Ecto.Changeset{}
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_params, @optional_params)
    |> common_changeset
  end

  @required_registration_params ~w(name email password password_confirmation)
  @optional_registration_params ~w(active)

  @spec registration_changeset(map() | %Ecto.Changeset{}, map()) :: %Ecto.Changeset{}
  def registration_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_registration_params, @optional_registration_params)
    |> common_changeset
  end

  @required_profile_params ~w(name email)
  @optional_profile_params ~w(active password password_confirmation)

  @spec profile_changeset(map() | %Ecto.Changeset{}, map()) :: %Ecto.Changeset{}
  def profile_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_profile_params, @optional_profile_params)
    |> common_changeset
  end

  @spec common_changeset(%Ecto.Changeset{}) :: %Ecto.Changeset{}
  defp common_changeset(changeset) do
    changeset
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
