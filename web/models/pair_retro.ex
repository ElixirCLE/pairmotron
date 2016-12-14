defmodule Pairmotron.PairRetro do
  use Pairmotron.Web, :model

  schema "pair_retros" do
    field :comment, :string
    belongs_to :user, Pairmotron.User
    belongs_to :pair, Pairmotron.Pair

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:comment])
    |> validate_required([:comment])
  end
end
