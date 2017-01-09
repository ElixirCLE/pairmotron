defmodule Pairmotron.Repo.Migrations.CreateRole do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :name, :string
      add :is_admin, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:roles, [:name])

    alter table(:users) do
      add :role_id, references(:roles, on_delete: :nilify_all)
    end

  end
end
