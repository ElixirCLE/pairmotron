defmodule Pairmotron.Repo.Migrations.ExtendPairRetroReflection do
  use Ecto.Migration

  def up do
    alter table(:pair_retros) do
      modify :reflection, :text
    end
  end

  def down do
    alter table(:pair_retros) do
      modify :reflection, :string
    end
  end
end
