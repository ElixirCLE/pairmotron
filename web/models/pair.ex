defmodule Pairmotron.Pair do
  use Pairmotron.Web, :model

  schema "pairs" do
    field :year, :integer
    field :week, :integer
    many_to_many :users, Pairmotron.User, join_through: Pairmotron.UserPair
    has_many :pair_retros, Pairmotron.PairRetro
    belongs_to :group, Pairmotron.Group

    timestamps()
  end

  @required_fields ~w(year week group_id)
  @optional_fields ~w()

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
  end
end
