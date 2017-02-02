defmodule Determination do
  defstruct dead_pairs: [], dead_user_pairs: [], available_users: []
end

defmodule Pairmotron.PairBuilder do
  @moduledoc """
  Provides ways of determining what has changed between an existing set of %UserPair{}s and a new
  set of %Users{}s that need to be paired.
  %UserPair{}s are, for the intent of this module,  records of how users were paired previously.

  This module will only spell out what needs to be changed between how users have already been
  paired and what users are now able to be paired.
  %Pair{}s and %UserPair{}s may either not change or be deleted.
  %Users{}s will be free to find a new pair.
  """


  @doc """
  Find the dead pairs, dead user pairs, and available users given the previous %UserPair{} records
  and the new list of %User{}s.
  """
  def determify(user_pairs, users) do
    dead_user_pairs = find_dead_user_pairs(user_pairs, users)
    %Determination{
      dead_pairs: dead_user_pairs |> find_dead_pairs,
      dead_user_pairs: dead_user_pairs,
      available_users: dead_user_pairs |> find_users_to_pair(user_pairs, users)
    }
  end

  @doc """
  Finds the previous %UserPair{}s that will no longer be needed with the new user set.
  """
  def find_dead_user_pairs([], _), do: []
  def find_dead_user_pairs(user_pairs, []), do: user_pairs
  def find_dead_user_pairs(user_pairs, users) do
    previously_paired_users = user_pairs |> pair_users |> MapSet.new
    u = users |> MapSet.new
    dead_users = MapSet.difference(previously_paired_users, u) |> MapSet.to_list
    dead_user_pairs = dead_users
      |> Enum.reduce([], fn(dead_user, dup) ->
        dup ++ Enum.filter(user_pairs, fn(p) -> p.user == dead_user end)
      end)
    dead_matched_user_pairs = dead_user_pairs
      |> Enum.reduce([], fn(dead_user_pair, dead_matched_user_pairs) ->
        dead_matched_user_pairs ++ Enum.filter(user_pairs, fn(p) -> p.pair == dead_user_pair.pair && p.id != dead_user_pair.id end)
      end)
    dead_user_pairs ++ dead_matched_user_pairs |> Enum.uniq
  end

  @doc """
  Finds the %Users{}s that will need to be paired because either their previous pair is no longer
  valid or the were not previously paired.
  """
  def find_users_to_pair(_, []), do: []
  def find_users_to_pair([], users), do: users
  def find_users_to_pair(user_pairs, users) do
    find_users_to_pair(find_dead_user_pairs(user_pairs, users), user_pairs, users)
  end

  @doc """
  Finds the %Pair{}s that are no longer valid with the new user set.
  """
  def find_dead_pairs([], _), do: []
  def find_dead_pairs(user_pairs, []), do: user_pairs |> unique_pairs
  def find_dead_pairs(user_pairs, users) do
    find_dead_user_pairs(user_pairs, users) |> find_dead_pairs
  end

  defp find_dead_pairs(dead_user_pairs) do
    dead_user_pairs |> unique_pairs
  end

  defp find_users_to_pair(dead_user_pairs, user_pairs, users) do
    unchanged_users = user_pairs
      |> MapSet.new
      |> MapSet.difference(dead_user_pairs |> MapSet.new)
      |> MapSet.to_list
      |> pair_users
      |> MapSet.new
    users
      |> MapSet.new
      |> MapSet.difference(unchanged_users)
      |> MapSet.to_list
  end

  defp unique_pairs(user_pairs), do: user_pairs |> Enum.map(fn(up) -> up.pair end) |> Enum.uniq

  defp pair_users(user_pairs), do: user_pairs |> Enum.map(fn(up) -> up.user end)
end
