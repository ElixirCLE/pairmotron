defmodule Pairmotron.PairRetroView do
  use Pairmotron.Web, :view

  def value_from_changeset(changeset, value) do
    elem(Ecto.Changeset.fetch_field(changeset, value), 1)
  end

  def format_date(nil), do: ""
  def format_date(date), do: Ecto.Date.to_string(date)
end
