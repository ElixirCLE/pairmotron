defmodule Pairmotron.GroupPairView do
  use Pairmotron.Web, :view
  import Pairmotron.PairView, only: [current_user_in_pair: 2, user_retro: 1]

  def past_week?(week, year) do
    Pairmotron.Calendar.past_week?(week, year, Timex.today)
  end
end
