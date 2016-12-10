defmodule Pairmotron.Project do
  use Pairmotron.Web, :model

  schema "projects" do
    field :name, :string
    field :description, :string
    field :url, :string

    timestamps()
  end

  @required_params ~w(name)
  @optional_params ~w(description url)

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_params, @optional_params)
    |> validate_url(:url)
  end

  def validate_url(changeset, field) do
    validate_change changeset, field, fn _, url ->
      case url |> URI.parse do
        %URI{scheme: nil} -> [{field, "URL is missing the scheme. Include 'http://' or 'https://'."}]
        %URI{host: nil} -> [{field, "URL is not valid."}]
        _ -> []
      end
    end
  end
end
