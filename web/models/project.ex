defmodule Pairmotron.Project do
  @moduledoc """
  A Project is something that the Users in a Pair can work on together.
  Projects are group specific.

  Any member of a group can create a project, but only the owner of the group
  or the creator of the project can modify the project once it exists.
  """
  use Pairmotron.Web, :model

  schema "projects" do
    field :name, :string
    field :description, :string
    field :url, :string

    has_many :pair_retros, Pairmotron.PairRetro
    belongs_to :group, Pairmotron.Group
    belongs_to :created_by, Pairmotron.User

    timestamps()
  end

  @required_params ~w(name)
  @optional_params ~w(description url group_id created_by_id)

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @spec changeset(map() | %Ecto.Changeset{}, map()) :: %Ecto.Changeset{}
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_params, @optional_params)
    |> validate_url(:url)
  end

  @required_create_params ~w(name group_id created_by_id)
  @optional_change_params ~w(description url)

  @spec changeset_for_create(map() | %Ecto.Changeset{}, map(), [Types.group]) :: %Ecto.Changeset{}
  def changeset_for_create(struct, params \\ %{}, users_groups) do
    struct
    |> cast(params, @required_create_params, @optional_change_params)
    |> validate_url(:url)
    |> validate_user_is_in_group(:group_id, users_groups)
  end

  @spec changeset_for_update(map() | %Ecto.Changeset{}, map()) :: %Ecto.Changeset{}
  def changeset_for_update(struct, params \\ %{}) do
    struct
    |> cast(params, @required_params, @optional_change_params)
    |> validate_url(:url)
  end

  @spec validate_url(%Ecto.Changeset{}, atom()) :: %Ecto.Changeset{}
  def validate_url(changeset, field) do
    validate_change changeset, field, fn _, url ->
      case url |> URI.parse do
        %URI{scheme: nil} -> [{field, "URL is missing the scheme. Include 'http://' or 'https://'."}]
        %URI{host: nil} -> [{field, "URL is not valid."}]
        _ -> []
      end
    end
  end

  @spec validate_user_is_in_group(%Ecto.Changeset{}, atom(), [Types.group]) :: %Ecto.Changeset{}
  def validate_user_is_in_group(changeset, field, users_groups) do
    validate_change changeset, field, fn _, selected_group_id ->
      if group_id_in_groups(selected_group_id, users_groups) do
        []
      else
        [{field, "Must be member of group"}]
      end
    end
  end

  @spec group_id_in_groups(integer(), [Types.group]) :: boolean()
  defp group_id_in_groups(group_id, groups) do
    groups |> Enum.any?(&(&1.id == group_id))
  end

  @spec projects_for_user(Types.user) :: %Ecto.Query{}
  def projects_for_user(user) do
    from project in Pairmotron.Project,
    join: group in assoc(project, :group),
    join: u in assoc(group, :users),
    where: u.id == ^user.id
  end

  @spec projects_for_group(Types.group | integer() | binary()) :: %Ecto.Query{}
  def projects_for_group(group = %Pairmotron.Group{}), do: projects_for_group(group.id)
  def projects_for_group(group_id) do
    from project in Pairmotron.Project,
    where: project.group_id == ^group_id
  end
end
