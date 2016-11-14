defmodule Pairmotron.Repo.Migrations.CreatePair do
  use Ecto.Migration

  def change do
    create table(:pairs) do
      add :year, :integer, primary_key: true
      add :week, :integer, primary_key: true
      add :pair_group, :integer

      timestamps()
    end
    create index(:pairs, [:year, :week])

  end
end
