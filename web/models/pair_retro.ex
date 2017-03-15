defmodule Pairmotron.PairRetro do
  @moduledoc """
  A PairRetro is short for "pair retrospective". It is a User's thoughts and
  statements about what they worked on for a specific pair.

  One retrospective can be created per User per Pair. Users cannot see what
  other Users have entered for their retrospectives.

  Retrospectives also have the subtle purpose of marking that a pair actually
  occurred. If a group's pairs are repairified, they will try not to delete
  pairs that already have an existing retrospective under the assumption that
  this pair already occurred and so the Users in that pair are not able to be
  paired again.
  """
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
  @spec changeset(map() | %Ecto.Changeset{}, map(), Types.pair, Types.project) :: %Ecto.Changeset{}
  def changeset(struct, params \\ %{}, pair, project) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> Sanitizer.sanitize([:subject, :reflection])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:pair_id)
    |> foreign_key_constraint(:project_id)
    |> validate_date_is_not_before_pair(:pair_date, pair)
    |> validate_field_is_not_in_future(:pair_date)
    |> validate_project_is_for_group(:project_id, pair, project)
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
  @spec update_changeset(map() | %Ecto.Changeset{}, map(), Types.pair, Types.project) :: %Ecto.Changeset{}
  def update_changeset(struct, params \\ %{}, pair, project) do
    struct
    |> cast(params, @required_update_fields, @optional_fields)
    |> Sanitizer.sanitize([:subject, :reflection])
    |> foreign_key_constraint(:project_id)
    |> validate_date_is_not_before_pair(:pair_date, pair)
    |> validate_field_is_not_in_future(:pair_date)
    |> validate_project_is_for_group(:project_id, pair, project)
  end

  @spec validate_date_is_not_before_pair(%Ecto.Changeset{}, atom(), nil | Types.pair) :: %Ecto.Changeset{}
  defp validate_date_is_not_before_pair(changeset, _, nil), do: changeset
  defp validate_date_is_not_before_pair(changeset, field, pair) do
    pair_start_date = Pairmotron.Calendar.first_date_of_week(pair.year, pair.week)
    validate_change changeset, field, fn field, field_date ->
      if Timex.before?(Ecto.Date.to_erl(field_date), pair_start_date) do
        [{field, "cannot be before the week of the pair"}]
      else
        []
      end
    end
  end

  @spec validate_field_is_not_in_future(%Ecto.Changeset{}, atom()) :: %Ecto.Changeset{}
  defp validate_field_is_not_in_future(changeset, field) do
    validate_change changeset, field, fn field, field_date ->
      if Timex.after?(Ecto.Date.to_erl(field_date), Timex.today) do
        [{field, "cannot be in the future"}]
      else
        []
      end
    end
  end

  @spec validate_project_is_for_group(%Ecto.Changeset{}, atom(), Types.pair, Types.project) :: %Ecto.Changeset{}
  defp validate_project_is_for_group(changeset, _, nil, _), do: changeset
  defp validate_project_is_for_group(changeset, _, _, nil), do: changeset
  defp validate_project_is_for_group(changeset, field, pair, project) do
    validate_change changeset, field, fn field, project_id ->
      cond do
        pair.group_id != project.group_id ->
          [{field, "Must belong to the pair's group"}]
        project.id != project_id ->
          [{field, "Must have same id as passed in project's id"}]
        true -> []
      end
    end
  end

  @spec retro_for_user_and_week(Types.user, integer(), 1..53) :: %Ecto.Query{}
  def retro_for_user_and_week(user, year, week) do
    from retro in Pairmotron.PairRetro,
    join: p in assoc(retro, :pair),
    where: retro.user_id == ^user.id,
    where: p.year == ^year,
    where: p.week == ^week
  end

  @spec users_retros(Types.user) :: %Ecto.Query{}
  def users_retros(user) do
    from retro in Pairmotron.PairRetro,
    where: retro.user_id == ^user.id
  end
end
