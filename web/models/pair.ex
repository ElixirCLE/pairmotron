defmodule Pairmotron.Pair do
  use Pairmotron.Web, :model

  schema "pairs" do
    field :year, :integer
    field :week, :integer
    many_to_many :users, Pairmotron.User, join_through: "users_pairs"
    has_many :pair_retros, Pairmotron.PairRetro

    @required_fields ~w(year week)
    @optional_fields ~w()

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
  end
end
