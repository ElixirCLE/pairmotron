defmodule Pairmotron.Repo.Migrations.AddEmailDisabledToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :email_enabled, :boolean, default: true, null: false
    end
  end
end
