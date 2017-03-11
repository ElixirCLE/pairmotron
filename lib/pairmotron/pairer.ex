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

  @spec generate_pairs([Types.user], [Types.pair]) :: [Types.pair]
  def generate_pairs(users, []), do: generate_pairs(users)
  def generate_pairs(users, pairs) do
    users
      |> chunk
      |> Enum.reverse
      |> friendify
      |> Enum.reverse
      |> unlonelify(pairs |> Enum.sort_by(fn(p) -> length(p.users) end) |> Enum.reverse)
  end

  @spec generate_pairs([Types.user]) :: %PairerResult{pairs: [Types.pair]}
  def generate_pairs(users) do
    users
      |> chunk
      |> unlonelify
  end

  defp chunk(users) do
    users
      |> Enum.chunk(2, 2, [])
  end

  defp unlonelify(pairs) do
    results = pairs
      |> Enum.reverse
      |> friendify
      |> Enum.reverse
    %PairerResult{pairs: results}
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
  defp friendify([[single] | [pair | rest]]) do
    [[single | pair] | rest]
  end
  defp friendify(pairs), do: pairs

end
