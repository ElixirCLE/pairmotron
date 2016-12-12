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
  end
end
