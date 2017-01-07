defmodule Pairmotron.Role do
  use Pairmotron.Web, :model

  schema "roles" do
    field :name, :string
    field :is_admin, :boolean, default: false

    has_many :users, Pairmotron.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :is_admin])
    |> validate_required([:name, :is_admin])
    |> unique_constraint(:name)
  end
end
