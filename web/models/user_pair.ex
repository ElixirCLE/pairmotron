defmodule Pairmotron.UserPair do
  @moduledoc """
  A UserPair joins together Users and Pairs and is used to represent a
  specific User being in a specific Pair.
  """
  use Pairmotron.Web, :model

  schema "users_pairs" do
    belongs_to :user, Pairmotron.User
    belongs_to :pair, Pairmotron.Pair

    @all_fields ~w(pair_id user_id)
    @required_fields [:pair_id, :user_id]

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @spec changeset(map() | %Ecto.Changeset{}, map()) :: %Ecto.Changeset{}
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
end
