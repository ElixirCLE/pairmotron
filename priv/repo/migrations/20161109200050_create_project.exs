defmodule Pairmotron.Repo.Migrations.CreateProject do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :string
      add :description, :string
      add :url, :string

      timestamps()
    end

  end
end
