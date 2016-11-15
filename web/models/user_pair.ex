defmodule Pairmotron.UserPair do
  use Pairmotron.Web, :model

  schema "users_pairs" do
    belongs_to :user, Pairmotron.User
    belongs_to :pair, Pairmotron.Pair

    @required_fields ~w(pair_id user_id)
    @optional_fields ~w()

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
  end
end
