defmodule Pairmotron.Repo.Migrations.CreatePairRetro do
  use Ecto.Migration

  def change do
    create table(:pair_retros) do
      add :comment, :string
      add :pair_id, references(:pairs)
      add :user_id, references(:users)

      timestamps()
    end

    create unique_index(:pair_retros, [:pair_id, :user_id])

  end
end
