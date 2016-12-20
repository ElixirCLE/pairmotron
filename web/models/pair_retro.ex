defmodule Pairmotron.PairRetro do
  use Pairmotron.Web, :model

  schema "pair_retros" do
    field :pair_date, Ecto.Date
    field :subject, :string
    field :reflection, :string
    belongs_to :user, Pairmotron.User
    belongs_to :pair, Pairmotron.Pair
    belongs_to :project, Pairmotron.Project

    timestamps()
  end

  @required_fields ~w(pair_date user_id pair_id)
  @optional_fields ~w(subject reflection project_id)

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:pair_id)
    |> foreign_key_constraint(:project_id)
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
