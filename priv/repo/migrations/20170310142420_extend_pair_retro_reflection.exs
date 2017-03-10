defmodule Pairmotron.Repo.Migrations.ExtendPairRetroReflection do
  use Ecto.Migration

  def change do
    alter table(:pair_retros) do
      modify :reflection, :text
    end

  end
end
