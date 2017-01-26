defmodule Pairmotron.Repo.Migrations.SetIsAdminDefault do
  use Ecto.Migration

  def up do
    execute "UPDATE users SET is_admin = FALSE where is_admin IS NULL"

    alter table(:users) do
      modify :is_admin, :boolean, null: false, default: false
    end
  end

  def down do
    alter table(:users) do
      modify :is_admin, :boolean, null: true, default: nil
    end
  end
end
