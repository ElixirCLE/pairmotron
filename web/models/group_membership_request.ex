defmodule Pairmotron.GroupMembershipRequest do
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
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_params, @optional_params)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:group_id)
    |> unique_constraint(:user_id_group_id, [message: "User is already invited to this group"])
  end

  def users_changeset(struct, params \\ %{}, group) do
    changeset(struct, params)
    |> validate_user_not_in_group(:user_id, group)
  end

  def validate_user_not_in_group(changeset, field, group) do
    validate_change changeset, field, fn _, user_id ->
      groups_user_ids = Enum.map(group.users, &(&1.id))
      cond do
        user_id in groups_user_ids ->
          [{field, "User is already in this group"}]
        true -> []
      end
    end
  end
end
