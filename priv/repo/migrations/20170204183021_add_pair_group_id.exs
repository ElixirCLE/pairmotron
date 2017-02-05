defmodule Pairmotron.Repo.Migrations.AddPairGroupId do
  use Ecto.Migration

  def change do
    alter table(:pairs) do
      add :group_id, references(:groups, on_delete: :nilify_all)
    end

  end
end
