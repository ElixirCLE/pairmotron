defmodule Pairmotron.Group do
  @moduledoc """
  Groups contain users and allow certain aspects of Pairmotron to be siloed on
  a per group basis.

  Groups have their own set of pairs, and Users can be in pairs of multiple
  Groups at the same time. Groups also have their own set of projects.

  Groups also have their own configuration options for how users are paired.
  (Not yet implemented)
  """
  use Pairmotron.Web, :model

  schema "groups" do
    field :name, :string
    field :description, :string
    belongs_to :owner, Pairmotron.User
    many_to_many :users, Pairmotron.User, join_through: Pairmotron.UserGroup
    has_many :projects, Pairmotron.Project
    has_many :group_membership_requests, Pairmotron.GroupMembershipRequest

    timestamps()
  end

  @required_fields ~w(name owner_id)
  @optional_fields ~w(description)

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @spec changeset(map() | %Ecto.Changeset{}, map()) :: %Ecto.Changeset{}
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:owner_id)
  end

  @doc """
  Builds a changeset and sets the users association. Should be used
  when creating a group so that the owner can be set as the only user.
  """
  @spec changeset_for_create(map() | %Ecto.Changeset{}, map(), list(Types.user)) :: %Ecto.Changeset{}
  def changeset_for_create(struct, params \\ %{}, users) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:owner_id)
    |> put_assoc(:users, users)
  end

  @spec groups_for_user(Types.user) :: %Ecto.Query{}
  def groups_for_user(user) do
    from group in Pairmotron.Group,
    join: u in assoc(group, :users),
    where: u.id == ^user.id
  end
end
