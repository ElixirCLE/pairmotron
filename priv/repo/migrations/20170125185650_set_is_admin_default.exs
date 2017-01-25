defmodule Pairmotron.Repo.Migrations.SetIsAdminDefault do
  use Ecto.Migration

  def up do
    alter table(:users) do
      modify :is_admin, :boolean, default: false
    end

    execute "UPDATE users SET is_admin = FALSE where is_admin IS NULL"
  end

  def down do
  end
end
