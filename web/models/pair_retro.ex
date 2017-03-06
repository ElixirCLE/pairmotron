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

  pair_start_date should be a date which is the first day
  of the week and year on the associated pair. It is used
  to validate that the pair_date of this pair_retro is after
  that date, since the actual pairing could not have occurred
  before the actual pair was assigned.

  Validates that the selected project is associated with the group tht is
  associated with the pair.
  """
  def changeset(struct, params \\ %{}, project, pair) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:pair_id)
    |> foreign_key_constraint(:project_id)
    |> validate_date_is_not_before_pair(:pair_date, pair)
    |> validate_field_is_not_in_future(:pair_date)
    |> validate_project_is_for_group(:project_id, project, pair)
  end

  @required_update_fields ~w(pair_date)

  @doc """
  Builds a changeset based on the `struct` and `params`.

  pair_start_date should be a date which is the first day
  of the week and year on the associated pair. It is used
  to validate that the pair_date of this pair_retro is after
  that date, since the actual pairing could not have occurred
  before the actual pair was assigned.

  The update changeset does not allow the user to change the user or pair
  associated with the pair_retro.
  """
  def update_changeset(struct, params \\ %{}, project, pair) do
    struct
    |> cast(params, @required_update_fields, @optional_fields)
    |> foreign_key_constraint(:project_id)
    |> validate_date_is_not_before_pair(:pair_date, pair)
    |> validate_field_is_not_in_future(:pair_date)
    |> validate_project_is_for_group(:project_id, project, pair)
  end

  defp validate_date_is_not_before_pair(changeset, field, pair) do
    pair_start_date = cond do
      is_nil(pair) -> nil
      true -> Pairmotron.Calendar.first_date_of_week(pair.year, pair.week)
    end
    validate_change changeset, field, fn field, field_date ->
      cond do
        is_nil(pair_start_date) -> []
        Timex.before?(Ecto.Date.to_erl(field_date), pair_start_date) ->
          [{field, "cannot be before the week of the pair"}]
        true -> []
      end
    end
  end

  defp validate_field_is_not_in_future(changeset, field) do
    validate_change changeset, field, fn field, field_date ->
      cond do
        Timex.after?(Ecto.Date.to_erl(field_date), Timex.today) ->
          [{field, "cannot be in the future"}]
        true -> []
      end
    end
  end

  defp validate_project_is_for_group(changeset, field, project, pair) do
    validate_change changeset, field, fn field, project_id ->
      cond do
        is_nil(project) -> []
        is_nil(pair) -> []
        pair.group_id != project.group_id ->
          [{field, "Must belong to the pair's group"}]
        project.id != project_id ->
          [{field, "Must have same id as passed in project's id"}]
        true -> []
      end
    end
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
