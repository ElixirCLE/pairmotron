defmodule Pairmotron.Repo.Migrations.UpdateExistingPairsToExistingGroup do
  use Ecto.Migration

  def up do
    execute "update pairs set group_id = (select id from groups order by id limit 1);"
  end

  def down do
    execute "update pairs set group_id = NULL;"
  end
end
