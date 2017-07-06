defmodule Pairmotron.Repo.Migrations.AddEmailDisabledToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :email_disabled, :boolean, default: false, null: false
    end
  end
end
