defmodule Pairmotron.PairMaker do
  @moduledoc """
  Provides functions to retrieve and/or generate pairs for a given time period and group.
  """
  require Logger
  import Ecto.Query
  alias Pairmotron.{Repo, Group, Pair, Mixer, Pairer, PairBuilder}

  @doc """
  Retrieves pairs for a given period and group. Generates pairs if none are found.
  """
  @spec fetch_or_gen(number, number, number) :: {:ok, List.t} | {:error, String.t}
  def fetch_or_gen(year, week, group_id) do
    case fetch_pairs(year, week, group_id) do
      []    -> generate_and_fetch_if_current_week(year, week, group_id)
      pairs -> {:ok, pairs}
    end
  end

  defp generate_and_fetch_if_current_week(year, week, group_id) do
    case Pairmotron.Calendar.same_week?(year, week, Timex.today) do
      true ->
        result = generate_pairs(year, week, group_id)
        pairs = fetch_pairs(year, week, group_id)
        prepare_result(result, pairs)
      false ->
        result = {:error, "Not current week"}
        pairs = []
        prepare_result(result, pairs)
    end
  end

  defp prepare_result({:error, message}, pairs), do: {:error, pairs, message}
  defp prepare_result({:ok, _}, pairs), do: {:ok, pairs}

  defp fetch_pairs(year, week, group_id) do
    Pair
      |> where(year: ^year, week: ^week, group_id: ^group_id)
      |> order_by(:id)
      |> preload(:users)
      |> Repo.all
  end

  @doc """
  Creates pairs for the period and group. This function will remove any pairs no longer necessary
  and add pairs as appropriate. This is done in one big transaction for data integrity.
  """
  @spec generate_pairs(number, number, number) :: {:ok, nil} | {:error, String.t}
  def generate_pairs(year, week, group_id) do
    group = Group
      |> select([g], g)
      |> where([g], g.id == ^group_id)
      |> preload(:users)
      |> Repo.one

    users = group.users
      |> Enum.filter(fn(u) -> u.active end)
      |> Enum.sort

    existing_pairs = fetch_pairs(year, week, group_id)

    determination = PairBuilder.determify(existing_pairs, users)

    pairs = determination.remaining_pairs
      |> Repo.preload(:pair_retros)
      |> Enum.filter(&(Enum.empty?(&1.pair_retros)))

    results = determination.available_users
      |> Mixer.mixify(week)
      |> Pairer.generate_pairs(pairs)

    Ecto.Multi.new
      |> remove_dead_pairs(determination.dead_pairs)
      |> insert_pairs(results.pairs, year, week, group_id)
      |> insert_lone_user_pair(results.user_pair)
      |> commit_transaction(year, week, group_id)
  end

  defp remove_dead_pairs(multi, dead_pairs) do
    # The atom name in multi functions needs to be unique to the multi.
    # We are using the index to avoid creating enough new atoms to reach the atom-limit.
    dead_pairs
      |> Enum.with_index
      |> Enum.reduce(multi, fn({pair, index}, acc) ->
          atom = String.to_atom("remove_dead_pair_#{index}")
          acc |> Ecto.Multi.delete(atom, pair)
      end)
  end

  defp insert_lone_user_pair(multi, nil), do: multi
  defp insert_lone_user_pair(multi, user_pair) do
    multi |> Ecto.Multi.insert(:create_lone_user_pair, user_pair)
  end

  defp insert_pairs(multi, pairs, year, week, group_id) do
    pairs
      |> Enum.with_index
      |> Enum.reduce(multi, fn({users, index}, acc) ->
          insert_pair(acc, {year, week, group_id}, users, index)
      end)
  end

  defp insert_pair(multi, {year, week, group_id}, users, index) do
    # The atom name in multi functions needs to be unique to the multi.
    # We are using the index to avoid creating enough new atoms to reach the atom-limit.
    atom = String.to_atom("insert_pair_#{index}")
    pair = %Pair{}
      |> Pair.changeset(%{year: year, week: week, group_id: group_id})
      |> Ecto.Changeset.put_assoc(:users, users)
    multi |> Ecto.Multi.insert(atom, pair)
  end

  defp commit_transaction(multi, year, week, group_id) do
    case Repo.transaction(multi) do
      {:error, failed_operation, failed_value, _} ->
        Logger.error "Generating pairs failed"
        Logger.error "Year: #{year}, week: #{week}, group_id: #{group_id}"
        Logger.error "#{failed_operation}"
        Logger.error "#{failed_value}"
        {:error, "Sorry, generating pairs failed"}
      {:ok, _} ->
        {:ok, nil}
    end
  end
end
