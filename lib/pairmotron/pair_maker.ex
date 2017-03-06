defmodule Pairmotron.PairMaker do
  require Logger
  import Ecto.Query
  alias Pairmotron.{Repo, Group, Pair, Mixer, Pairer, PairBuilder}

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

  def generate_pairs(year, week, group_id) do
    group = Group
      |> select([g], g)
      |> where([g], g.id == ^group_id)
      |> preload(:users)
      |> Repo.one

    users = group.users
      |> Enum.filter(fn(u) -> u.active end)
      |> Enum.sort

    pairs = fetch_pairs(year, week, group_id)
      |> Repo.preload(:users)

    determination = PairBuilder.determify(pairs, users)

    multi = Ecto.Multi.new

    multi = determination.dead_pairs
      |> Enum.reduce(multi, fn(pair, acc) ->
          acc |> Ecto.Multi.delete(:remove_dead_pairs, pair)
      end)

    pairs = determination.remaining_pairs
      |> Repo.preload(:pair_retros)
      |> Enum.filter(&(Enum.empty?(&1.pair_retros)))

    results = determination.available_users
      |> Mixer.mixify(week)
      |> Pairer.generate_pairs(pairs)

    multi = results.pairs
      |> Enum.reduce(multi, fn(users, acc) ->
          insert_pair(acc, year, week, group_id, users)
      end)

    multi = insert_lone_user_pair(multi, results.user_pair)
    case Repo.transaction(multi) do
      {:error, failed_operation, failed_value, _} ->
        Logger.error "Generating pairs failed"
        Logger.error "Year: #{year}, week: #{week}, group_id: #{group_id}"
        Logger.error "#{IO.inspect(failed_operation)}"
        Logger.error "#{IO.inspect(failed_value)}"
        {:error, "Sorry, generating pairs failed"}
      {:ok, _} ->
        {:ok, nil}
    end
  end

  defp insert_lone_user_pair(multi, nil), do: multi
  defp insert_lone_user_pair(multi, user_pair) do
    multi |> Ecto.Multi.insert(:create_lone_user_pair, user_pair)
  end

  defp insert_pair(multi, year, week, group_id, users) do
    atom = String.to_atom("insert_pair_#{year}_#{week}_#{group_id}_#{hd(users).id}")
    pair = Pair.changeset(%Pair{}, %{year: year, week: week, group_id: group_id})
      |> Ecto.Changeset.put_assoc(:users, users)
    multi |> Ecto.Multi.insert(atom, pair)
  end
end
