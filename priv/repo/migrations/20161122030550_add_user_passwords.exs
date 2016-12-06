defmodule Pairmotron.Repo.Migrations.AddUserPasswords do
  use Ecto.Migration

  def up do
    default_hash = Comeonin.Bcrypt.hashpwsalt("password") 

    alter table(:users) do 
      add :password_hash, :string
    end

    flush

    Pairmotron.Repo.update_all("users", set: [password_hash: default_hash])

    alter table(:users) do
      modify :password_hash, :string, null: false
    end

    create unique_index(:users, [:email])
  end

  def down do
    alter table(:users) do
      remove :password_hash
    end

    drop unique_index(:users, [:email])
  end
end
