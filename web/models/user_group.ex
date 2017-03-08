defmodule Pairmotron.UserGroup do
  @moduledoc """
  A UserGroup joins together Users and Groups and is used to represent a
  specific User being a member of a specific Group.
  """
  use Pairmotron.Web, :model

  schema "users_groups" do
    belongs_to :user, Pairmotron.User
    belongs_to :group, Pairmotron.Group

    @required_fields ~w(group_id user_id)
    @optional_fields ~w()

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @spec changeset(map() | %Ecto.Changeset{}, map()) :: %Ecto.Changeset{}
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:user_id_group_id, [:user_id, :group_id])
  end
end
