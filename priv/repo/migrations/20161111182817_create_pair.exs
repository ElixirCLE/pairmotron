defmodule Pairmotron.Repo.Migrations.CreatePair do
  use Ecto.Migration

  def change do
    create table(:pairs) do
      add :year, :integer, primary_key: true
      add :week, :integer, primary_key: true
      add :pair_group, :integer
      add :user_id, references(:users, on_delete: :nothing), primary_key: true

      timestamps()
    end
    create index(:pairs, [:user_id, :year, :week])

  end
end
