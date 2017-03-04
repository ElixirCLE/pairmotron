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

  @doc """
  Ecto query that returns a pair with its :users association prelodaded.
  Performs a single database call.
  """
  def pair_with_users(pair_id) when is_binary(pair_id), do:
    Integer.parse(pair_id) |> elem(0) |> pair_with_users
  def pair_with_users(pair_id) do
    from pair in Pairmotron.Pair,
    join: users in assoc(pair, :users),
    where: pair.id == ^pair_id,
    preload: [users: users]
  end

  def pair_with_users_and_group(pair_id) do
    from pair in Pairmotron.Pair,
    left_join: users in assoc(pair, :users),
    left_join: group in assoc(pair, :group),
    where: pair.id == ^pair_id,
    preload: [users: users, group: group]
  end
end
