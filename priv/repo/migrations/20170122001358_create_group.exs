defmodule Pairmotron.Repo.Migrations.CreateGroup do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :name, :string
      add :owner_id, references(:users)

      timestamps()
    end

    create unique_index(:groups, [:name])

    create table(:users_groups) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :group_id, references(:groups, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:users_groups, [:user_id, :group_id])

  end
end
