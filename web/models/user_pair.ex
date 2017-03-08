defmodule Pairmotron.UserPair do
  @moduledoc """
  A UserPair joins together Users and Pairss and is used to represent a
  specific User being in a specific Pair.
  """
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
  @spec changeset(map() | %Ecto.Changeset{}, map()) :: %Ecto.Changeset{}
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
  end
end
