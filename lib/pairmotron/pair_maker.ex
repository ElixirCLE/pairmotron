defmodule Pairmotron.PairMaker do
  import Ecto.Query
  alias Pairmotron.{Repo, Group, Pair, Mixer, Pairer, PairBuilder}

  def fetch_or_gen(year, week, group_id) do
    case fetch_pairs(year, week, group_id) do
      []    -> generate_and_fetch_if_current_week(year, week, group_id)
      pairs -> pairs
    end
      |> Repo.preload([:users])
  end

  defp generate_and_fetch_if_current_week(year, week, group_id) do
    case Pairmotron.Calendar.same_week?(year, week, Timex.today) do
      true ->
        generate_pairs(year, week, group_id)
        fetch_pairs(year, week, group_id)
      false -> []
    end
  end

  defp fetch_pairs(year, week, group_id) do
    Pair
      |> where(year: ^year, week: ^week, group_id: ^group_id)
      |> order_by(:id)
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
    Repo.transaction(multi)
  end

  defp insert_lone_user_pair(multi, nil), do: multi
  defp insert_lone_user_pair(multi, user_pair) do
    multi |> Ecto.Multi.insert(:create_lone_user_pair, user_pair)
  end

  defp insert_pair(multi, year, week, group_id, users) do
    pair = Pair.changeset(%Pair{}, %{year: year, week: week, group_id: group_id})
      |> Ecto.Changeset.put_assoc(:users, users)
    multi |> Ecto.Multi.insert(:insert_pair, pair)
  end
end
