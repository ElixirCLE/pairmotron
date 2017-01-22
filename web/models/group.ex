defmodule Pairmotron.Group do
  use Pairmotron.Web, :model

  schema "groups" do
    field :name, :string
    belongs_to :owner, Pairmotron.User
    many_to_many :users, Pairmotron.User, join_through: "users_groups"

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :owner_id])
    |> validate_required([:name])
  end
end
