defmodule Pairmotron.Repo.Migrations.AddPeriodToPair do
  use Ecto.Migration

  def up do
    alter table(:pairs) do
      add :period, :daterange
    end
    execute "update pairs set period = ('[' || to_timestamp(week || ' '  ||  year,'IW IYYY')::date || ',' || to_timestamp(week + 1 || ' '  ||  year,'IW IYYY')::date || ')')::daterange;"
    execute "create extension btree_gist;"
    execute "create index pair_period_index on pairs using GiST(period, group_id);"
  end

  def down do
    alter table(:pairs) do
      remove :period
    end
    execute "drop index if exists group_pairing_period_index;"
    execute "drop extension btree_gist;"
  end
end
