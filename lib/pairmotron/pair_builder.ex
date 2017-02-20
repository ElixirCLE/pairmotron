defmodule Determination do
  @moduledoc """
  Provides all the results of the PairBuilder.

  dead_pairs will be a list of %Pair{}s indicating safe-to-delete pairs.
  remaining_pairs will be a list of %Pair{}s that are not safe-to-delete.
    The expectation is that is list will be further filtered and used in determining how to build
    pairs from the available users.
  available_users will be a list of %User{}s that should go through the pairing process.
    These are users that are not in a remaining pair but should be placed in a pair.
  """
  defstruct dead_pairs: [], remaining_pairs: [], available_users: []
end

defmodule Pairmotron.PairBuilder do
  @moduledoc """
  Provides ways of determining what has changed between an existing set of %Pair{}s and a new
  set of %Users{}s that need to be paired.

  This module will only spell out the difference between how users have already been paired and
  what users are now able to be paired.
  %Pair{}s may either not change or be deleted.
  """


  @doc """
  Find the dead pairs, remaining pairs, and available users given the previous %Pair{} records
  and the new list of %User{}s.
  """
  def determify(pairs, users) do
    dead_pairs = find_dead_pairs(pairs, users)
    %Determination{
      dead_pairs: dead_pairs,
      remaining_pairs: dead_pairs |> find_remaining_pairs(pairs),
      available_users: dead_pairs |> find_available_users(pairs, users)
    }
  end

  defp find_dead_pairs([], _), do: []
  defp find_dead_pairs(pairs, []), do: pairs
  defp find_dead_pairs(pairs, users) do
    users_set = users
      |> MapSet.new
    previously_paired_users_set = pairs
      |> pair_users
      |> MapSet.new
    dead_users = previously_paired_users_set
      |> MapSet.difference(users_set)
      |> MapSet.to_list
    dead_pairs = dead_users
      |> Enum.map(fn dead_user -> Enum.find(pairs, &(dead_user in &1.users)) end)
      |> Enum.filter(&(!is_nil(&1)))
    pairs
      |> Enum.filter(&(length(&1.users) == 1))
      |> Enum.concat(dead_pairs)
      |> Enum.uniq
  end

  defp find_available_users(_, _, []), do: []
  defp find_available_users(dead_pairs, pairs, users) do
    unchanged_users_set = find_remaining_pairs(dead_pairs, pairs)
      |> pair_users
      |> MapSet.new
    users
      |> MapSet.new
      |> MapSet.difference(unchanged_users_set)
      |> MapSet.to_list
  end

  defp find_remaining_pairs(dead_pairs, pairs) do
    pairs
      |> MapSet.new
      |> MapSet.difference(dead_pairs |> MapSet.new)
      |> MapSet.to_list
  end

  defp pair_users(pairs), do: pairs |> Enum.flat_map(fn(up) -> up.users end)
end
