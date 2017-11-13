defmodule PairerResult do
  @moduledoc """
  Return struct for Pairmotron.Pairer.generate_pairs.
  """
  defstruct user_pair: nil, pairs: []
end

defmodule Pairmotron.Pairer do
  @moduledoc """
  Responsible for pairing up a list of users into pairs and returning this as a
  PairerResult.
  """

  alias Pairmotron.{Pair, Types, UserPair}

  @spec generate_pairs([Types.user], [Types.pair]) :: %PairerResult{}
  # No existing pairs. Generate new ones.
  def generate_pairs(users, []), do: generate_new_pairs(users)
  def generate_pairs([user], pairs) do
    # Just one user to add. Sort the list so that shorter pairs are first.
    # Recurse the list until we find a pair we can add the single user to (1 or
    # 2 users in pair). If we don't find a suitable pair, create a new single
    # user pair.
    unlonelify([[user]], pairs |> sort_pairs_by_length)
  end
  def generate_pairs(users, _pairs) do
    # More than one user to add. Let Accomplice group the new users into pairs
    # just like it would if there were no pairs. Old pairs are not relevant.
    generate_new_pairs(users)
  end

  @spec generate_new_pairs([Types.user]) :: %PairerResult{pairs: [Types.pair]}
  defp generate_new_pairs([]), do: %PairerResult{pairs: []}
  defp generate_new_pairs([user]), do: %PairerResult{pairs: [[user]]}
  defp generate_new_pairs(users) do
    pairs = users |> Accomplice.group(%{minimum: 2, ideal: 2, maximum: 3})
    %PairerResult{pairs: pairs}
  end

  defp sort_pairs_by_length(pairs) do
    pairs |> Enum.sort_by(fn(pair) -> length(pair.users) end)
  end

  defp unlonelify([[single]], []), do: %PairerResult{pairs: [[single]]}
  defp unlonelify([[single]], [pair = %Pair{users: [_1]} | _]) do
    %PairerResult{user_pair: UserPair.changeset(%UserPair{}, %{pair_id: pair.id, user_id: single.id})}
  end
  defp unlonelify([[single]], [pair = %Pair{users: [_1, _2]} | _]) do
    %PairerResult{user_pair: UserPair.changeset(%UserPair{}, %{pair_id: pair.id, user_id: single.id})}
  end
  defp unlonelify([[single]], [%Pair{users: [_1, _2, _3]} | pairs]), do: unlonelify([[single]], pairs)

end
