defmodule Pairmotron.Repo.Migrations.AddCreatedByToRetro do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :created_by_id, references(:users, on_delete: :nilify_all)
    end
  end
end
