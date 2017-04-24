defmodule Pairmotron.Repo.Migrations.AddPeriodLengthToGroup do
  use Ecto.Migration

  def change do
    alter table(:groups) do
      add :period_length, :integer, default: 7
    end

  end
end
