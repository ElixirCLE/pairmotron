defmodule Pairmotron.Group do
  use Pairmotron.Web, :model

  schema "groups" do
    field :name, :string
    belongs_to :owner, Pairmotron.User
    many_to_many :users, Pairmotron.User, join_through: Pairmotron.UserGroup
    has_many :projects, Pairmotron.Project
    has_many :group_membership_requests, Pairmotron.GroupMembershipRequest

    timestamps()
  end

  @required_fields ~w(name owner_id)
  @optional_fields ~w()

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:owner_id)
  end

  @doc """
  Builds a changeset and sets the users association. Should be used
  when creating a group so that the owner can be set as the only user.
  """
  def changeset_for_create(struct, params \\ %{}, users) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:owner_id)
    |> put_assoc(:users, users)
  end

  def groups_for_user(user) do
    from group in Pairmotron.Group,
    join: u in assoc(group, :users),
    where: u.id == ^user.id
  end
end
