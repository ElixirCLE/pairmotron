defmodule Pairmotron.Repo.Migrations.RemoveRoleTable do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :role_id
    end

    drop table(:roles)

  end
end
