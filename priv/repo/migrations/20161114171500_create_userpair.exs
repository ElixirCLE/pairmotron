defmodule Pairmotron.Repo.Migrations.CreateUserPair do
  use Ecto.Migration

  def change do
    create unique_index(:pairs, [:id])

    create table(:users_pairs) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :pair_id, references(:pairs, on_delete: :delete_all)

      timestamps()
    end
    create index(:users_pairs, [:user_id])
    create index(:users_pairs, [:pair_id])

  end
end
