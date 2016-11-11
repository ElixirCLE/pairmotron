defmodule Pairmotron.Pair do
  use Pairmotron.Web, :model

  schema "pairs" do
    field :year, :integer
    field :week, :integer
    field :pair_group, :integer
    belongs_to :user, Pairmotron.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:year, :week, :pair_group, :user_id])
    |> validate_required([:year, :week, :pair_group, :user_id])
  end
end
