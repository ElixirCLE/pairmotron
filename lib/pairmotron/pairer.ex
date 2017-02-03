defmodule PairerResult do
  defstruct user_pair: nil, pairs: []
end

defmodule Pairmotron.Pairer do

  alias Pairmotron.UserPair

  def generate_pairs(users, []), do: generate_pairs(users)
  def generate_pairs(users, user_pairs) do
    users
      |> chunk
      |> unlonelify(user_pairs)
  end

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
  defp unlonelify(pairs = [[ _f, _s]], _), do: %PairerResult{pairs: pairs}
  defp unlonelify([[single]], [user_pair | _user_pairs]) do
    %PairerResult{user_pair: UserPair.changeset(%UserPair{}, %{pair_id: user_pair.pair_id, user_id: single.id})}
  end

  defp friendify(pairs = [ [_first, _second] | _rest]), do: pairs
  defp friendify([[single] | [pair | rest]]) do
    [[single | pair] | rest]
  end
  defp friendify(pairs), do: pairs

end
