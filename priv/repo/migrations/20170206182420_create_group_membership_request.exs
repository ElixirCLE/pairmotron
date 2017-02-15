defmodule Pairmotron.Repo.Migrations.CreateGroupMembershipRequest do
  use Ecto.Migration

  def change do
    create table(:group_membership_requests) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :group_id, references(:groups, on_delete: :delete_all), null: false
      add :initiated_by_user, :boolean, null: false

      timestamps()
    end

    create unique_index(:group_membership_requests, [:user_id, :group_id])

  end
end
