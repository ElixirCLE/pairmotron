defmodule Pairmotron.Project do
  use Pairmotron.Web, :model

  schema "projects" do
    field :name, :string
    field :description, :string
    field :url, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description, :url])
    |> validate_required([:name, :description, :url])
  end
end
