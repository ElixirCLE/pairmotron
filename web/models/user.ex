defmodule Pairmotron.User do
  use Pairmotron.Web, :model

  schema "users" do
    field :name, :string
    field :email, :string
    field :active, :boolean

    timestamps()
  end

  @required_params [:name, :email]
  @optional_params [:active]

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_params, @optional_params)
    |> validate_required([:name, :email])
  end

  def active_users do
    Pairmotron.User
    |> Ecto.Query.where([u], u.active)
  end
end
