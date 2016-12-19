defmodule Pairmotron.PairRetro do
  use Pairmotron.Web, :model

  schema "pair_retros" do
    field :pair_date, Ecto.Date
    field :comment, :string
    belongs_to :user, Pairmotron.User
    belongs_to :pair, Pairmotron.Pair

    timestamps()
  end

  @required_fields ~w(comment pair_date)
  @optional_fields ~w(user_id pair_id)

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
  end

  def retro_for_user_and_week(user, year, week) do
    from retro in Pairmotron.PairRetro,
    join: p in assoc(retro, :pair),
    where: retro.user_id == ^user.id,
    where: p.year == ^year,
    where: p.week == ^week
  end

  def users_retros(user) do
    from retro in Pairmotron.PairRetro,
    where: retro.user_id == ^user.id
  end
end
