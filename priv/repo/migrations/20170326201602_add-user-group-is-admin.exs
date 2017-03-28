defmodule :"Elixir.Pairmotron.Repo.Migrations.Add-user-group-is-admin" do
  use Ecto.Migration

  def change do
    alter table (:users_groups) do
      add :is_admin, :boolean, null: false, default: false
    end
  end
end
