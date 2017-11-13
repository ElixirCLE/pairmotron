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
  def generate_pairs(users, []), do: generate_pairs(users)
  def generate_pairs(users, pairs) do
    sorted_pairs = pairs |> sort_pairs_by_length
    users
      |> chunk
      |> Enum.reverse
      |> friendify
      |> Enum.reverse
      |> unlonelify(sorted_pairs)
  end

  @spec generate_pairs([Types.user]) :: %PairerResult{pairs: [Types.pair]}
  def generate_pairs([]), do: %PairerResult{pairs: []}
  def generate_pairs([user]), do: %PairerResult{pairs: [[user]]}
  def generate_pairs(users) do
    case users |> Accomplice.group(%{minimum: 2, ideal: 2, maximum: 3}) do
      :impossible -> :impossible
      pairs -> %PairerResult{pairs: pairs}
    end
  end

  defp chunk(users) do
    users
      |> Enum.chunk(2, 2, [])
  end

  defp sort_pairs_by_length(pairs) do
    pairs |> Enum.sort_by(fn(pair) -> -length(pair.users) end)
  end

  defp unlonelify([], _), do: %PairerResult{}
  defp unlonelify(users = [[_1, _2]], _), do: %PairerResult{pairs: users}
  defp unlonelify(users = [[_1, _2, _3]], _), do: %PairerResult{pairs: users}
  defp unlonelify(users = [[_1, _2] | _], _), do: %PairerResult{pairs: users}
  defp unlonelify(users = [[_]], [%Pair{users: [_1, _2, _3]}]), do: %PairerResult{pairs: users}
  defp unlonelify([[single]], [pair = %Pair{users: [_1, _2]}]) do
    %PairerResult{user_pair: UserPair.changeset(%UserPair{}, %{pair_id: pair.id, user_id: single.id})}
  end
  defp unlonelify([[single]], [pair = %Pair{users: [_1]}]) do
    %PairerResult{user_pair: UserPair.changeset(%UserPair{}, %{pair_id: pair.id, user_id: single.id})}
  end
  defp unlonelify([[single]], [pair = %Pair{users: [_1]} | _]) do
    %PairerResult{user_pair: UserPair.changeset(%UserPair{}, %{pair_id: pair.id, user_id: single.id})}
  end
  defp unlonelify([[single]], [%Pair{users: [_1, _2]} | pairs]), do: unlonelify([[single]], pairs)
  defp unlonelify([[single]], [%Pair{users: [_1, _2, _3]} | pairs]), do: unlonelify([[single]], pairs)

  defp friendify(pairs = [[_first, _second] | _rest]), do: pairs
  defp friendify([[single], pair | rest]) do
    [[single | pair] | rest]
  end
  defp friendify(pairs), do: pairs

end
