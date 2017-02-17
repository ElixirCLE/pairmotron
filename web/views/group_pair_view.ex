defmodule Pairmotron.GroupPairView do
  use Pairmotron.Web, :view

  def past_week?(week, year) do
    Pairmotron.Calendar.past_week?(week, year, Timex.today)
  end
end
