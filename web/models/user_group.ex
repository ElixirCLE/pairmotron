defmodule Pairmotron.UserGroup do
  @moduledoc """
  A UserGroup joins together Users and Groups and is used to represent a
  specific User being a member of a specific Group.
  """
  use Pairmotron.Web, :model

  schema "users_groups" do
    field :is_admin, :boolean

    belongs_to :user, Pairmotron.User
    belongs_to :group, Pairmotron.Group

    @all_fields ~w(group_id user_id is_admin)
    @required_fields [:group_id, :user_id]

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @spec changeset(map() | Ecto.Changeset.t, map()) :: Ecto.Changeset.t
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:user_id_group_id, [:user_id, :group_id])
  end

  @all_update_fields ~w(is_admin)
  @required_update_fields [:is_admin]

  @doc """
  Builds a changeset for use when updating an existing UserGroup entry.
  
  Does not allow the modification of the associated user or group.
  """
  @spec update_changeset(map() | Ecto.Changeset.t, map()) :: Ecto.Changeset.t
  def update_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_update_fields)
    |> validate_required(@required_update_fields) 
  end

  @doc """
  Returns a query to retrieve the UserGroup associated with the user and group
  along with the :user and :group associations preloaded.
  """
  @spec user_group_for_user_and_group(integer() | binary(), integer() | binary()) :: Ecto.Query.t
  def user_group_for_user_and_group(user_id, group_id) do
    from user_group in Pairmotron.UserGroup,
    join: user in assoc(user_group, :user),
    join: group in assoc(user_group, :group),
    where: user.id == ^user_id,
    where: group.id == ^group_id,
    preload: [user: user, group: group]
  end
end
