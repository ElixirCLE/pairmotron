defmodule Pairmotron.Repo.Migrations.AddGroupToProject do
  use Ecto.Migration

  def change do

    alter table(:projects) do
      add :group_id, references(:groups, on_delete: :delete_all)
    end

  end
end
