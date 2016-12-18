defmodule Pairmotron.PairRetroView do
  use Pairmotron.Web, :view

  def value_from_changeset(changeset, value) do
    elem(Ecto.Changeset.fetch_field(changeset, value), 1)
  end
end
