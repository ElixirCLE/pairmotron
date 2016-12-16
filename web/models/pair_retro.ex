defmodule Pairmotron.PairRetro do
  use Pairmotron.Web, :model

  schema "pair_retros" do
    field :comment, :string
    belongs_to :user, Pairmotron.User
    belongs_to :pair, Pairmotron.Pair

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:comment], [:user_id, :pair_id])
    |> validate_required([:comment])
  end

  def retro_for_user_and_week(user, year, week) do
    from retro in Pairmotron.PairRetro,
    join: u in assoc(retro, :user),
    join: p in assoc(retro, :pair),
    where: u.id == ^user.id,
    where: p.year == ^year,
    where: p.week == ^week
  end
end
