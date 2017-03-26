defmodule :"Elixir.Pairmotron.Repo.Migrations.Add-user-group-is-admin" do
  use Ecto.Migration

  def up do
    alter table(:users_groups) do
      add :is_admin, :boolean
    end

    execute "UPDATE users_groups SET is_admin = FALSE where is_admin IS NULL"

    alter table (:users_groups) do
      modify :is_admin, :boolean, null: false, default: false
    end
  end

  def down do
    alter table(:users_groups) do
      remove :is_admin
    end
  end
end
