defmodule Pairmotron.Repo.Migrations.CreatePasswordResetToken do
  use Ecto.Migration

  def change do
    create table(:password_reset_tokens) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :token, :string

      timestamps()
    end

  end
end
