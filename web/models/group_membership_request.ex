defmodule Pairmotron.GroupMembershipRequest do
  @moduledoc """
  A GroupMembershipRequest represents an invitation to/from a Group from/to a
  User to become a member of the Group. Users can request membership to a group
  which creates a GroupMembershipRequest with initiated_by_user equal to true.
  Similarly, Group Owners (or those in the group with sufficient roles) can
  invite a specific User to the group, which creates a GroupMembershipRequest
  with initiated_by_user equal to false.

  Users can accept an invitation if there exists a GroupMembershipRequest
  between that User and that Group with initiated_by_user equal to false, which
  deletes that GroupMembershipRequest and adds a UserGroup record between the
  User and the Group, indicating that the User is a member of that Group.

  Similarly, Groups can accept a request from a User to join the group if there
  exists a GroupMembershipRequest between that User and that Group with
  initiated_by_user equal to true, which deletes the GroupMemberhsipRequest and
  adds a UserGroup record between the User and the group, indicating that the
  User is a member of that Group.
  """
  use Pairmotron.Web, :model

  schema "group_membership_requests" do
    field :initiated_by_user, :boolean
    belongs_to :user, Pairmotron.User
    belongs_to :group, Pairmotron.Group

    timestamps()
  end

  @required_params ~w(initiated_by_user user_id group_id)
  @optional_params ~w()

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @spec changeset(map() | %Ecto.Changeset{}, map()) :: %Ecto.Changeset{}
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_params, @optional_params)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:group_id)
    |> unique_constraint(:user_id_group_id, [message: "User is already invited to this group"])
  end

  @spec users_changeset(map() | %Ecto.Changeset{}, map(), Types.group) :: %Ecto.Changeset{}
  def users_changeset(struct, params \\ %{}, group) do
    struct
    |> changeset(struct)
    |> validate_user_not_in_group(:user_id, group)
  end

  @spec validate_user_not_in_group(%Ecto.Changeset{}, atom(), Types.group) :: [] | [{atom(), binary()}]
  defp validate_user_not_in_group(changeset, field, group) do
    validate_change changeset, field, fn _, user_id ->
      groups_user_ids = Enum.map(group.users, &(&1.id))
      if user_id in groups_user_ids do
        [{field, "User is already in this group"}]
      else
        []
      end
    end
  end
end
