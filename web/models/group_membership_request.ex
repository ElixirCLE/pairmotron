defmodule Pairmotron.GroupMembershipRequest do
  use Pairmotron.Web, :model

  alias Pairmotron.GroupMembershipRequest

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
    |> unique_constraint(:user_id_group_id, [:user_id, :group_id])
  end
end
