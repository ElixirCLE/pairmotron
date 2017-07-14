defmodule Pairmotron.Pair do
  @moduledoc """
  A Pair is made up of 1 to 3 Users and corresponds to those Users pairing for
  a certain period of time

  A Pair can also have a number of PairRetros up to the number of users in that
  Pair which contain information about what each user did during that pair.
  """
  use Pairmotron.Web, :model

  schema "pairs" do
    field :year, :integer
    field :week, :integer
    field :period, Pairmotron.Daterange
    many_to_many :users, Pairmotron.User, join_through: Pairmotron.UserPair
    has_many :pair_retros, Pairmotron.PairRetro
    belongs_to :group, Pairmotron.Group

    timestamps()
  end

  @all_fields ~w(year week group_id period)
  @required_fields [:year, :week, :group_id]

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @spec changeset(map() | %Ecto.Changeset{}, map()) :: %Ecto.Changeset{}
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> update_period()
  end

  @spec update_period(map() | %Ecto.Changeset{}) :: %Ecto.Changeset{}
  defp update_period(changeset) do
    # probably want to filter for only changes to :year and :week
    case changeset.valid? do
      true ->
        {_, year} = Ecto.Changeset.fetch_field(changeset, :year)
        {_, week} = Ecto.Changeset.fetch_field(changeset, :week)
        Ecto.Changeset.put_change(changeset, :period, Pairmotron.Interval.new(Timex.from_iso_triplet({year, week, 1}), Timex.from_iso_triplet({year, week, 7})))
      _ -> changeset
    end
  end

  @doc """
  Ecto query that returns a pair with its :users association prelodaded.
  Performs a single database call.
  """
  @spec pair_with_users(integer() | binary()) :: %Ecto.Query{}
  def pair_with_users(pair_id) do
    from pair in Pairmotron.Pair,
    left_join: users in assoc(pair, :users),
    where: pair.id == ^pair_id,
    preload: [users: users]
  end
end
