defmodule Pairmotron.Repo.Migrations.CreatePairRetro do
  use Ecto.Migration

  def change do
    create table(:pair_retros) do
      add :comment, :string
      add :pair_date, :date
      add :pair_id, references(:pairs, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)
      add :project_id, references(:projects, on_delete: :nilify_all)

      timestamps()
    end

    create unique_index(:pair_retros, [:pair_id, :user_id])

  end
end
